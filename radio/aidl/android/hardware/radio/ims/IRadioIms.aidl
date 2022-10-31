/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package android.hardware.radio.ims;

import android.hardware.radio.AccessNetwork;
import android.hardware.radio.ims.EpsFallbackReason;
import android.hardware.radio.ims.ImsRegistration;
import android.hardware.radio.ims.ImsStreamDirection;
import android.hardware.radio.ims.ImsTrafficType;
import android.hardware.radio.ims.IRadioImsIndication;
import android.hardware.radio.ims.IRadioImsResponse;
import android.hardware.radio.ims.SrvccCall;
import android.hardware.radio.ims.ImsStreamDirection;
import android.hardware.radio.ims.ImsStreamType;

/**
 * This interface is used by IMS telephony layer to talk to cellular radio.
 * All the functions have minimum one parameter:
 * serial: which corresponds to serial no. of request. Serial numbers must only be memorized for the
 * duration of a method call. If clients provide colliding serials (including passing the same
 * serial to different methods), multiple responses (one for each method call) must still be served.
 * setResponseFunctions must work with IRadioImsResponse and IRadioImsIndication.
 */
@VintfStability
oneway interface IRadioIms {
    /**
     * Provides a list of SRVCC call information to radio.
     *
     * @param serial Serial number of request
     * @param srvccCalls the list of calls
     *
     * Response function is IRadioImsResponse.setSrvccCallInfoResponse()
     */
    void setSrvccCallInfo(int serial, in SrvccCall[] srvccCalls);

    /**
     * Update the IMS registration information to the radio.
     *
     * This information shall be used by radio to implement following carrier requirements:
     * 1) Graceful IMS PDN disconnection on cellular when NAS is about to perform detach
     * eg. SIM removal or SIM refresh
     * 2) Block PLMN or RAT based on the IMS registration failure reason
     *
     * @param serial Serial number of request
     * @param imsRegistration IMS registration information
     *
     * Response function is IRadioImsResponse.updateImsRegistrationInfoResponse()
     */
    void updateImsRegistrationInfo(int serial, in ImsRegistration imsRegistration);

    /**
     * IMS stack notifies the NAS and RRC layers of the radio that the upcoming IMS traffic is
     * for the service mentioned in the ImsTrafficType. If this API is not
     * explicitly invoked and IMS module sends traffic on IMS PDN then the radio
     * shall treat type as background data traffic type.
     * This API shall be used by modem
     *  1. To set the appropriate establishment cause in RRC connection request.
     *  2. To prioritize RF resources in case of DSDS. The service priority is
     * EMERGENCY > EMERGENCY SMS > VOICE > VIDEO > SMS > REGISTRATION > Ut/XCAP. The RF
     * shall be prioritized to the subscription which handles higher priority service.
     * When both subscriptions are handling the same type of service then RF shall be
     * prioritized to the voice preferred sub.
     *  3. To evaluate the overall access barring in the case of ACB, ACB-Skp/SCM,
     * SSAC and UAC. If the specific failure including network access, modem
     * internal and RF resource prioritization from the modem happen,
     * {@link IRadioImsResponse#startImsTrafficResponse()} or
     * {@link IRadioImsIndication#onConnectionSetupFailure()} shall be invoked with the
     * failure reason.
     *
     * @param serial Serial number of request
     * @param token A nonce to identify the request
     * @param imsTrafficType IMS traffic type like registration, voice, and video
     * @param accessNetworkType The type of the radio access network used
     *
     * Response function is IRadioImsResponse.startImsTrafficResponse()
     */
    void startImsTraffic(int serial, in String token,
            ImsTrafficType imsTrafficType, AccessNetwork accessNetworkType);

    /**
     * Indicates IMS traffic has been stopped.
     * For all IMS traffic, notified with startImsTraffic, IMS service shall notify
     * stopImsTraffic when it completes the traffic specified by the token.
     *
     * @param serial Serial number of request
     * @param token The token assigned by startImsTraffic()
     *
     * Response function is IRadioImsResponse.stopImsTrafficResponse()
     */
    void stopImsTraffic(int serial, in String token);

    /**
     * Triggers the UE initiated EPS fallback when a MO voice call failed to establish on 5G NR
     * network and network didn't initiate a fallback.
     *
     * @param serial Serial number of request
     * @param reason Specifies the reason that causes EPS fallback
     *
     * Response function is IRadioImsResponse.triggerEpsFallbackResponse()
     */
    void triggerEpsFallback(int serial, in EpsFallbackReason reason);

    /**
     * Set response functions for IMS radio requests and indications.
     *
     * @param radioImsResponse Object containing response functions
     * @param radioImsIndication Object containing radio indications
     */
    void setResponseFunctions(in IRadioImsResponse radioImsResponse,
            in IRadioImsIndication radioImsIndication);

    /**
     * Access Network Bitrate Recommendation Query (ANBRQ), see 3GPP TS 26.114.
     * This API triggers radio to send ANBRQ message
     * to the access network to query the desired bitrate.
     *
     * @param serial Serial number of request
     * @param mediaType Media type is used to identify media stream such as audio or video
     * @param direction Direction of this packet stream (e.g. uplink or downlink)
     * @param bitsPerSecond The bit rate requested by the opponent UE
     *
     * Response function is IRadioImsResponse.sendAnbrQueryResponse()
     */
    void sendAnbrQuery(int serial, ImsStreamType mediaType, ImsStreamDirection direction, int bitsPerSecond);
}