﻿/*The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is the TSO LoginServer.

The Initial Developer of the Original Code is
ddfczm. All Rights Reserved.

Contributor(s): ______________________________________.
*/

using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Sockets;
using TSOClient.Code.UI.Framework;
using TSOClient.Code.UI.Controls;
using TSOClient.Code.UI.Panels;
using TSOClient.Events;
using TSOClient.Network;
using TSOClient.Network.Events;
using GonzoNet;
using ProtocolAbstractionLibraryD;

namespace TSOClient.Code.UI.Screens
{
    public class CityTransitionScreen : GameScreen
    {
        private UIContainer m_BackgroundCtnr;
        private UIImage m_Background;
        private UILoginProgress m_LoginProgress;
        private CityInfo m_SelectedCity;
        private bool m_CharacterCreated = false;

        /// <summary>
        /// Creates a new CityTransitionScreen.
        /// </summary>
        /// <param name="SelectedCity">The city being transitioned to.</param>
        /// <param name="CharacterCreated">If transitioning from CreateASim, this should be true.
        /// A CharacterCreateCity packet will be sent to the CityServer. Otherwise, this should be false.
        /// A CityToken packet will be sent to the CityServer.</param>
        public CityTransitionScreen(CityInfo SelectedCity, bool CharacterCreated)
        {
            m_SelectedCity = SelectedCity;
            m_CharacterCreated = CharacterCreated;

            /**
             * Scale the whole screen to 1024
             */
            m_BackgroundCtnr = new UIContainer();
            m_BackgroundCtnr.ScaleX = m_BackgroundCtnr.ScaleY = ScreenWidth / 800.0f;

            /** Background image **/
            m_Background = new UIImage(GetTexture((ulong)FileIDs.UIFileIDs.setup));
            m_Background.ID = "Background";
            m_BackgroundCtnr.Add(m_Background);

            var lbl = new UILabel();
            lbl.Caption = "Version 1.1097.1.0";
            lbl.X = 20;
            lbl.Y = 558;
            m_BackgroundCtnr.Add(lbl);
            this.Add(m_BackgroundCtnr);

            m_LoginProgress = new UILoginProgress();
            m_LoginProgress.X = (ScreenWidth - (m_LoginProgress.Width + 20));
            m_LoginProgress.Y = (ScreenHeight - (m_LoginProgress.Height + 20));
            m_LoginProgress.Opacity = 0.9f;
            this.Add(m_LoginProgress);

            NetworkFacade.Controller.OnNetworkError += new NetworkErrorDelegate(Controller_OnNetworkError);

            LoginArgsContainer LoginArgs = new LoginArgsContainer();
            LoginArgs.Username = NetworkFacade.Client.ClientEncryptor.Username;
            LoginArgs.Enc = NetworkFacade.Client.ClientEncryptor;

            NetworkFacade.Client = new NetworkClient(SelectedCity.IP, SelectedCity.Port);
            //THIS IS IMPORTANT - THIS NEEDS TO BE COPIED AFTER IT HAS BEEN RECREATED FOR
            //THE RECONNECTION TO WORK!
            LoginArgs.Client = NetworkFacade.Client;
            NetworkFacade.Client.OnConnected += new OnConnectedDelegate(Client_OnConnected);
            NetworkFacade.Controller.Reconnect(ref NetworkFacade.Client, SelectedCity, LoginArgs);
            
            NetworkFacade.Controller.OnCharacterCreationStatus += new OnCharacterCreationStatusDelegate(Controller_OnCharacterCreationStatus);
            NetworkFacade.Controller.OnCityTransfer += new OnCityTransferStatus(Controller_OnCityTransfer);
        }

        ~CityTransitionScreen()
        {
            NetworkFacade.Controller.OnNetworkError -= new NetworkErrorDelegate(Controller_OnNetworkError);
            NetworkFacade.Controller.OnCharacterCreationStatus -= new OnCharacterCreationStatusDelegate(Controller_OnCharacterCreationStatus);
            NetworkFacade.Controller.OnCityTransfer -= new OnCityTransferStatus(Controller_OnCityTransfer);
        }

        private void Client_OnConnected(LoginArgsContainer LoginArgs)
        {
            TSOClient.Network.Events.ProgressEvent Progress = 
                new TSOClient.Network.Events.ProgressEvent(TSOClient.Events.EventCodes.PROGRESS_UPDATE);
            Progress.Done = 1;
            Progress.Total = 2;

            if (m_CharacterCreated)
            {
                UIPacketSenders.SendCharacterCreateCity(LoginArgs, PlayerAccount.CurrentlyActiveSim);
                OnTransitionProgress(Progress);
            }
            else
            {
                UIPacketSenders.SendCityToken(NetworkFacade.Client);
                OnTransitionProgress(Progress);
            }
        }

        /// <summary>
        /// Received a status update from the CityServer.
        /// Occurs after sending the token.
        /// </summary>
        /// <param name="e">Status of transfer.</param>
        private void Controller_OnCityTransfer(CityTransferStatus e)
        {
            switch (e)
            {
                case CityTransferStatus.Success:
                    OnTransitionProgress(new TSOClient.Network.Events.ProgressEvent(EventCodes.PROGRESS_UPDATE));
                    GameFacade.Controller.ShowCity();
                    break;
                case CityTransferStatus.GeneralError:
                    Controller_OnNetworkError(new SocketException());
                    break;
            }
        }

        /// <summary>
        /// Received a status update from the CityServer.
        /// Occurs after sending CharacterCreation packet.
        /// </summary>
        /// <param name="e">Status of character creation.</param>
        private void Controller_OnCharacterCreationStatus(CharacterCreationStatus e)
        {
            switch (e)
            {
                case CharacterCreationStatus.Success:
                    OnTransitionProgress(new TSOClient.Network.Events.ProgressEvent(EventCodes.PROGRESS_UPDATE));
                    GameFacade.Controller.ShowCity();
                    break;
                case CharacterCreationStatus.GeneralError:
                    Controller_OnNetworkError(new SocketException());
                    break;
            }
        }

        /// <summary>
        /// Another stage in the CityServer transition progress was done.
        /// </summary>
        /// <param name="e"></param>
        private void OnTransitionProgress(ProgressEvent e)
        {
            var stage = e.Done;

            m_LoginProgress.ProgressCaption = GameFacade.Strings.GetString("251", (stage + 4).ToString());
            m_LoginProgress.Progress = 25 * stage;
        }

        /// <summary>
        /// A network error occured - 95% of the time, this will be because
        /// a connection could not be established.
        /// </summary>
        /// <param name="Exception">The exception that occured.</param>
        private void Controller_OnNetworkError(SocketException Exception)
        {
            UIAlertOptions Options = new UIAlertOptions();
            Options.Message = GameFacade.Strings.GetString("210", "36 301");
            Options.Title = GameFacade.Strings.GetString("210", "40");
            Options.Buttons = UIAlertButtons.OK;
            UI.Framework.UIScreen.ShowAlert(Options, true);

            /** Reset **/
            //Note: A network error *should* never occur in this screen, so this code should never be called.
            GameFacade.Controller.ShowPersonSelection();
        }
    }
}