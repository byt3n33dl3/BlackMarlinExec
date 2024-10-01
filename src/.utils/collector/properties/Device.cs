using DeviceManagementLib.Win32;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DeviceManagementLib
{
    public class Device
    {
        private Guid classGuid;
        private static List<Guid> deviceClassGuids = new List<Guid>();

        static Device()
        {
            foreach (var guidString in deviceClassGuidStrings)
            {
                deviceClassGuids.Add(new Guid(guidString));
            }
        }

        public Device()
        { }

        public Device(Guid classGuid) : this()
        {
            this.classGuid = classGuid;
        }

        public Guid ClassGuid
        {
            get { return classGuid; }
        }

        #region DeviceClassGuid
        private static readonly string[] deviceClassGuidStrings = {
            "6bdd1fc1-810f-11d0-bec7-08002be2092f",
            "66f250d6-7801-4a64-b139-eea80a450b24",
            "7ebefbc0-3200-11d2-b4c2-00a0c9697d07",
            "4d36e964-e325-11ce-bfc1-08002be10318",
            "d45b1c18-c8fa-11d1-9f77-0000f805f530",
            "c06ff265-ae09-48f0-812c-16753d7cba83",
            "72631e54-78a4-11d0-bcf7-00aa00b7b32a",
            "53d29ef7-377c-4d14-864b-eb3a85769359",
            "e0cbf06c-cd8b-4647-bb8a-263b43f0f974",
            "4d36e965-e325-11ce-bfc1-08002be10318",
            "4d36e966-e325-11ce-bfc1-08002be10318",
            "6bdd1fc2-810f-11d0-bec7-08002be2092f",
            "4d36e967-e325-11ce-bfc1-08002be10318",
            "4d36e968-e325-11ce-bfc1-08002be10318",
            "48721b56-6795-11d2-b1a8-0080c72e74a2",
            "49ce6ac8-6f86-11d2-b1e5-0080c72e74a2",
            "c459df55-db08-11d1-b009-00a0c9081ff6",
            "4d36e969-e325-11ce-bfc1-08002be10318",
            "4d36e980-e325-11ce-bfc1-08002be10318",
            "6bdd1fc3-810f-11d0-bec7-08002be2092f",
            "4d36e96a-e325-11ce-bfc1-08002be10318",
            "745a17a0-74d3-11d0-b6fe-00a0c90f57da",
            "6bdd1fc6-810f-11d0-bec7-08002be2092f",
            "30ef7132-d858-4a0c-ac24-b9028a5cca3f",
            "6bdd1fc5-810f-11d0-bec7-08002be2092f",
            "4d36e96b-e325-11ce-bfc1-08002be10318",
            "8ecc055d-047f-11d1-a537-0000f8753ed1",
            "4d36e96c-e325-11ce-bfc1-08002be10318",
            "ce5939ae-ebde-11d0-b181-0000f8753ec4",
            "5099944a-f6b9-4057-a056-8c550228544c",
            "4d36e96d-e325-11ce-bfc1-08002be10318",
            "4d36e96e-e325-11ce-bfc1-08002be10318",
            "4d36e96f-e325-11ce-bfc1-08002be10318",
            "4d36e970-e325-11ce-bfc1-08002be10318",
            "4d36e971-e325-11ce-bfc1-08002be10318",
            "50906cb8-ba12-11d1-bf5d-0000f805f530",
            "4d36e972-e325-11ce-bfc1-08002be10318",
            "4d36e973-e325-11ce-bfc1-08002be10318",
            "4d36e974-e325-11ce-bfc1-08002be10318",
            "4d36e975-e325-11ce-bfc1-08002be10318",
            "4d36e976-e325-11ce-bfc1-08002be10318",
            "4d36e977-e325-11ce-bfc1-08002be10318",
            "4658ee7e-f050-11d1-b6bd-00c04fa372a7",
            "4d36e978-e325-11ce-bfc1-08002be10318",
            "4d36e979-e325-11ce-bfc1-08002be10318",
            "4d36e97a-e325-11ce-bfc1-08002be10318",
            "50127dc3-0f36-415e-a6cc-4cb3be910b65",
            "d48179be-ec20-11d1-b6b8-00c04fa372a7",
            "4d36e97b-e325-11ce-bfc1-08002be10318",
            "268c95a1-edfe-11d3-95c3-0010dc4050a5",
            "5175d334-c371-4806-b3ba-71fd53c9258d",
            "997b5d8d-c442-4f2e-baf3-9c8e671e9e21",
            "50dd5230-ba8a-11d1-bf5d-0000f805f530",
            "4d36e97c-e325-11ce-bfc1-08002be10318",
            "4d36e97d-e325-11ce-bfc1-08002be10318",
            "6d807884-7d21-11cf-801c-08002be10318",
            "4d36e97e-e325-11ce-bfc1-08002be10318",
            "36fc9e60-c465-11cf-8056-444553540000",
            "71a27cdd-812a-11d0-bec7-08002be2092f",
            "533c5b84-ec70-11d2-9505-00c04f79deaf",
            "25dbce51-6c8f-4a72-8a6d-b54c2b4fc835",
            "eec5ad98-8080-425f-922a-dabf3de3f69a",
            "9da2b80f-f89f-4a49-a5c2-511b085b9e8a",
        };
        #endregion DeviceClassGuid

        public static Guid[] DeviceClassGuids
        {
            get
            {
                return deviceClassGuids.ToArray();
            }
        }

        #region DEVPKEY
        internal static readonly Dictionary<string, DEVPROPKEY> DEVPKEY = new Dictionary<string, DEVPROPKEY>
        {
            { "DEVPKEY_NAME", new DEVPROPKEY("b725f130-47ef-101a-a5f1-02608c9eebac", 10) },
            { "DEVPKEY_Device_DeviceDesc", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 2) },
            { "DEVPKEY_Device_HardwareIds", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 3) },
            { "DEVPKEY_Device_CompatibleIds", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 4) },
            { "DEVPKEY_Device_Service", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 6) },
            { "DEVPKEY_Device_Class", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 9) },
            { "DEVPKEY_Device_ClassGuid", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 10) },
            { "DEVPKEY_Device_Driver", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 11) },
            { "DEVPKEY_Device_ConfigFlags", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 12) },
            { "DEVPKEY_Device_Manufacturer", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 13) },
            { "DEVPKEY_Device_FriendlyName", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 14) },
            { "DEVPKEY_Device_LocationInfo", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 15) },
            { "DEVPKEY_Device_PDOName", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 16) },
            { "DEVPKEY_Device_Capabilities", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 17) },
            { "DEVPKEY_Device_UINumber", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 18) },
            { "DEVPKEY_Device_UpperFilters", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 19) },
            { "DEVPKEY_Device_LowerFilters", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 20) },
            { "DEVPKEY_Device_BusTypeGd", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 21) },
            { "DEVPKEY_Device_LegacyBusType", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 22) },
            { "DEVPKEY_Device_BusNumber", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 23) },
            { "DEVPKEY_Device_EnumeratorName", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 24) },
            { "DEVPKEY_Device_Security", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 25) },
            { "DEVPKEY_Device_SecuritySDS", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 26) },
            { "DEVPKEY_Device_DevType", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 27) },
            { "DEVPKEY_Device_Exclusive", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 28) },
            { "DEVPKEY_Device_Characteristics", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 29) },
            { "DEVPKEY_Device_Address", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 30) },
            { "DEVPKEY_Device_UINumberDescFormat", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 31) },
            { "DEVPKEY_Device_PowerData", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 32) },
            { "DEVPKEY_Device_RemovalPolicy", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 33) },
            { "DEVPKEY_Device_RemovalPolicyDefault", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 34) },
            { "DEVPKEY_Device_RemovalPolicyOverride", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 35) },
            { "DEVPKEY_Device_InstallState", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 36) },
            { "DEVPKEY_Device_LocationPaths", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 37) },
            { "DEVPKEY_Device_BaseContainerId", new DEVPROPKEY("a45c254e-df1c-4efd-8020-67d146a850e0", 38) },
            { "DEVPKEY_Device_DevNodeStatus", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 2) },
            { "DEVPKEY_Device_ProblemCode", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 3) },
            { "DEVPKEY_Device_EjectionRelations", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 4) },
            { "DEVPKEY_Device_RemovalRelations", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 5) },
            { "DEVPKEY_Device_PowerRelations", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 6) },
            { "DEVPKEY_Device_BusRelations", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 7) },
            { "DEVPKEY_Device_Parent", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 8) },
            { "DEVPKEY_Device_Children", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 9) },
            { "DEVPKEY_Device_Siblings", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 10) },
            { "DEVPKEY_Device_TransportRelations", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 11) },
            { "DEVPKEY_Device_ProblemStatus", new DEVPROPKEY("4340a6c5-93fa-4706-972c-7b648008a5a7", 12) },
            { "DEVPKEY_Device_Reported", new DEVPROPKEY("80497100-8c73-48b9-aad9-ce387e19c56e", 2) },
            { "DEVPKEY_Device_Legacy", new DEVPROPKEY("80497100-8c73-48b9-aad9-ce387e19c56e", 3) },
            { "DEVPKEY_Device_ContainerId", new DEVPROPKEY("8c7ed206-3f8a-4827-b3ab-ae9e1faefc6c", 2) },
            { "DEVPKEY_Device_InLocalMachineContainer", new DEVPROPKEY("8c7ed206-3f8a-4827-b3ab-ae9e1faefc6c", 4) },
            { "DEVPKEY_Device_ModelId", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 2) },
            { "DEVPKEY_Device_FriendlyNameAttributes", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 3) },
            { "DEVPKEY_Device_ManufacturerAttributes", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 4) },
            { "DEVPKEY_Device_PresenceNotForDevice", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 5) },
            { "DEVPKEY_Device_SignalStrength", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 6) },
            { "DEVPKEY_Device_IsAssociateableByUserAction", new DEVPROPKEY("80d81ea6-7473-4b0c-8216-efc11a2c4c8b", 7) },
            { "DEVPKEY_Numa_Proximity_Domain", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 1) },
            { "DEVPKEY_Device_DHP_Rebalance_Policy", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 2) },
            { "DEVPKEY_Device_Numa_Node", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 3) },
            { "DEVPKEY_Device_BusReportedDeviceDesc", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 4) },
            { "DEVPKEY_Device_IsPresent", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 5) },
            { "DEVPKEY_Device_HasProblem", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 6) },
            { "DEVPKEY_Device_ConfigurationId", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 7) },
            { "DEVPKEY_Device_ReportedDeviceIdsHash", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 8) },
            { "DEVPKEY_Device_PhysicalDeviceLocation", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 9) },
            { "DEVPKEY_Device_BiosDeviceName", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 10) },
            { "DEVPKEY_Device_DriverProblemDesc", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 11) },
            { "DEVPKEY_Device_DebuggerSafe", new DEVPROPKEY("540b947e-8b40-45bc-a8a2-6a0b894cbda2", 12) },
            { "DEVPKEY_Device_SessionId", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 6) },
            { "DEVPKEY_Device_InstallDate", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 100) },
            { "DEVPKEY_Device_FirstInstallDate", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 101) },
            { "DEVPKEY_Device_LastArrivalDate", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 102) },
            { "DEVPKEY_Device_LastRemovalDate", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 103) },
            { "DEVPKEY_Device_DriverDate", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 2) },
            { "DEVPKEY_Device_DriverVersion", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 3) },
            { "DEVPKEY_Device_DriverDesc", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 4) },
            { "DEVPKEY_Device_DriverInfPath", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 5) },
            { "DEVPKEY_Device_DriverInfSection", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 6) },
            { "DEVPKEY_Device_DriverInfSectionExt", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 7) },
            { "DEVPKEY_Device_MatchingDeviceId", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 8) },
            { "DEVPKEY_Device_DriverProvider", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 9) },
            { "DEVPKEY_Device_DriverPropPageProvider", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 10) },
            { "DEVPKEY_Device_DriverCoInstallers", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 11) },
            { "DEVPKEY_Device_ResourcePickerTags", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 12) },
            { "DEVPKEY_Device_ResourcePickerExceptions", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 13) },
            { "DEVPKEY_Device_DriverRank", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 14) },
            { "DEVPKEY_Device_DriverLogoLevel", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 15) },
            { "DEVPKEY_Device_NoConnectSound", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 17) },
            { "DEVPKEY_Device_GenericDriverInstalled", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 18) },
            { "DEVPKEY_Device_AdditionalSoftwareRequested", new DEVPROPKEY("a8b865dd-2e3d-4094-ad97-e593a70c75d6", 19) },
            { "DEVPKEY_Device_SafeRemovalRequired", new DEVPROPKEY("afd97640-86a3-4210-b67c-289c41aabe55", 2) },
            { "DEVPKEY_Device_SafeRemovalRequiredOverride", new DEVPROPKEY("afd97640-86a3-4210-b67c-289c41aabe55", 3) },
            { "DEVPKEY_DrvPkg_Model", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 2) },
            { "DEVPKEY_DrvPkg_VendorWebSite", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 3) },
            { "DEVPKEY_DrvPkg_DetailedDescription", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 4) },
            { "DEVPKEY_DrvPkg_DocumentationLink", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 5) },
            { "DEVPKEY_DrvPkg_Icon", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 6) },
            { "DEVPKEY_DrvPkg_BrandingIcon", new DEVPROPKEY("cf73bb51-3abf-44a2-85e0-9a3dc7a12132", 7) },
            { "DEVPKEY_DeviceClass_UpperFilters", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 19) },
            { "DEVPKEY_DeviceClass_LowerFilters", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 20) },
            { "DEVPKEY_DeviceClass_Security", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 25) },
            { "DEVPKEY_DeviceClass_SecuritySDS", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 26) },
            { "DEVPKEY_DeviceClass_DevType", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 27) },
            { "DEVPKEY_DeviceClass_Exclusive", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 28) },
            { "DEVPKEY_DeviceClass_Characteristics", new DEVPROPKEY("4321918b-f69e-470d-a5de-4d88c75ad24b", 29) },
            { "DEVPKEY_DeviceClass_Name", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 2) },
            { "DEVPKEY_DeviceClass_ClassName", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 3) },
            { "DEVPKEY_DeviceClass_Icon", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 4) },
            { "DEVPKEY_DeviceClass_ClassInstaller", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 5) },
            { "DEVPKEY_DeviceClass_PropPageProvider", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 6) },
            { "DEVPKEY_DeviceClass_NoInstallClass", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 7) },
            { "DEVPKEY_DeviceClass_NoDisplayClass", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 8) },
            { "DEVPKEY_DeviceClass_SilentInstall", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 9) },
            { "DEVPKEY_DeviceClass_NoUseClass", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 10) },
            { "DEVPKEY_DeviceClass_DefaultService", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 11) },
            { "DEVPKEY_DeviceClass_IconPath", new DEVPROPKEY("259abffc-50a7-47ce-af08-68c9a7d73366", 12) },
            { "DEVPKEY_DeviceClass_DHPRebalanceOptOut", new DEVPROPKEY("d14d3ef3-66cf-4ba2-9d38-0ddb37ab4701", 2) },
            { "DEVPKEY_DeviceClass_ClassCoInstallers", new DEVPROPKEY("713d1703-a2e2-49f5-9214-56472ef3da5c", 2) },
            { "DEVPKEY_DeviceInterface_FriendlyName", new DEVPROPKEY("026e516e-b814-414b-83cd-856d6fef4822", 2) },
            { "DEVPKEY_DeviceInterface_Enabled", new DEVPROPKEY("026e516e-b814-414b-83cd-856d6fef4822", 3) },
            { "DEVPKEY_DeviceInterface_ClassGuid", new DEVPROPKEY("026e516e-b814-414b-83cd-856d6fef4822", 4) },
            { "DEVPKEY_DeviceInterface_ReferenceString", new DEVPROPKEY("026e516e-b814-414b-83cd-856d6fef4822", 5) },
            { "DEVPKEY_DeviceInterface_Restricted", new DEVPROPKEY("026e516e-b814-414b-83cd-856d6fef4822", 6) },
            { "DEVPKEY_DeviceInterfaceClass_DefaultInterface", new DEVPROPKEY("14c83a99-0b3f-44b7-be4c-a178d3990564", 2) },
            { "DEVPKEY_DeviceInterfaceClass_Name", new DEVPROPKEY("14c83a99-0b3f-44b7-be4c-a178d3990564", 3) },
            { "DEVPKEY_Device_Model", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 39) },
            { "DEVPKEY_DeviceContainer_Address", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 51) },
            { "DEVPKEY_DeviceContainer_DiscoveryMethod", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 52) },
            { "DEVPKEY_DeviceContainer_IsEncrypted", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 53) },
            { "DEVPKEY_DeviceContainer_IsAuthenticated", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 54) },
            { "DEVPKEY_DeviceContainer_IsConnected", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 55) },
            { "DEVPKEY_DeviceContainer_IsPaired", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 56) },
            { "DEVPKEY_DeviceContainer_Icon", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 57) },
            { "DEVPKEY_DeviceContainer_Version", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 65) },
            { "DEVPKEY_DeviceContainer_Last_Seen", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 66) },
            { "DEVPKEY_DeviceContainer_Last_Connected", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 67) },
            { "DEVPKEY_DeviceContainer_IsShowInDisconnectedState", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 68) },
            { "DEVPKEY_DeviceContainer_IsLocalMachine", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 70) },
            { "DEVPKEY_DeviceContainer_MetadataPath", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 71) },
            { "DEVPKEY_DeviceContainer_IsMetadataSearchInProgress", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 72) },
            { "DEVPKEY_DeviceContainer_MetadataChecksum", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 73) },
            { "DEVPKEY_DeviceContainer_IsNotInterestingForDisplay", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 74) },
            { "DEVPKEY_DeviceContainer_LaunchDeviceStageOnDeviceConnect", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 76) },
            { "DEVPKEY_DeviceContainer_LaunchDeviceStageFromExplorer", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 77) },
            { "DEVPKEY_DeviceContainer_BaselineExperienceId", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 78) },
            { "DEVPKEY_DeviceContainer_IsDeviceUniquelyIdentifiable", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 79) },
            { "DEVPKEY_DeviceContainer_AssociationArray", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 80) },
            { "DEVPKEY_DeviceContainer_DeviceDescription1", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 81) },
            { "DEVPKEY_DeviceContainer_DeviceDescription2", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 82) },
            { "DEVPKEY_DeviceContainer_HasProblem", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 83) },
            { "DEVPKEY_DeviceContainer_IsSharedDevice", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 84) },
            { "DEVPKEY_DeviceContainer_IsNetworkDevice", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 85) },
            { "DEVPKEY_DeviceContainer_IsDefaultDevice", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 86) },
            { "DEVPKEY_DeviceContainer_MetadataCabinet", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 87) },
            { "DEVPKEY_DeviceContainer_RequiresPairingElevation", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 88) },
            { "DEVPKEY_DeviceContainer_ExperienceId", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 89) },
            { "DEVPKEY_DeviceContainer_Category", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 90) },
            { "DEVPKEY_DeviceContainer_Category_Desc_Singular", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 91) },
            { "DEVPKEY_DeviceContainer_Category_Desc_Plural", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 92) },
            { "DEVPKEY_DeviceContainer_Category_Icon", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 93) },
            { "DEVPKEY_DeviceContainer_CategoryGroup_Desc", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 94) },
            { "DEVPKEY_DeviceContainer_CategoryGroup_Icon", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 95) },
            { "DEVPKEY_DeviceContainer_PrimaryCategory", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 97) },
            { "DEVPKEY_DeviceContainer_UnpairUninstall", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 98) },
            { "DEVPKEY_DeviceContainer_RequiresUninstallElevation", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 99) },
            { "DEVPKEY_DeviceContainer_DeviceFunctionSubRank", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 100) },
            { "DEVPKEY_DeviceContainer_AlwaysShowDeviceAsConnected", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 101) },
            { "DEVPKEY_DeviceContainer_ConfigFlags", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 105) },
            { "DEVPKEY_DeviceContainer_PrivilegedPackageFamilyNames", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 106) },
            { "DEVPKEY_DeviceContainer_CustomPrivilegedPackageFamilyNames", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 107) },
            { "DEVPKEY_DeviceContainer_IsRebootRequired", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 108) },
            { "DEVPKEY_Device_InstanceId", new DEVPROPKEY("78c34fc8-104a-4aca-9ea4-524d52996e57", 256) },
            { "DEVPKEY_DeviceContainer_FriendlyName", new DEVPROPKEY("656a3bb3-ecc0-43fd-8477-4ae0404a96cd", 12288) },
            { "DEVPKEY_DeviceContainer_Manufacturer", new DEVPROPKEY("656a3bb3-ecc0-43fd-8477-4ae0404a96cd", 8192) },
            { "DEVPKEY_DeviceContainer_ModelName", new DEVPROPKEY("656a3bb3-ecc0-43fd-8477-4ae0404a96cd", 8194) },
            { "DEVPKEY_DeviceContainer_ModelNumber", new DEVPROPKEY("656a3bb3-ecc0-43fd-8477-4ae0404a96cd", 8195) },
            { "DEVPKEY_DeviceContainer_InstallInProgress", new DEVPROPKEY("83da6326-97a6-4088-9453-a1923f573b29", 9) }
        };
        #endregion DEVPKEY

        internal Dictionary<DEVPROPKEY, object> Properties = new Dictionary<DEVPROPKEY, object>();

        public string Name
        {
            get
            {
                return (string)GetProperty("DEVPKEY_NAME");
            }
        }

        public DeviceCapabilities Capabilities
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_Capabilities");
                if (o == null)
                {
                    return (DeviceCapabilities)0u;
                }
                return (DeviceCapabilities)o;
            }
        }

        public DeviceConfigurationFlags ConfigurationFlags
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_ConfigFlags");
                if (o == null)
                {
                    return (DeviceConfigurationFlags)0u;
                }
                return (DeviceConfigurationFlags)o;
            }
        }

        public DeviceInstallState InstallState
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_InstallState");
                if (o == null)
                {
                    return DeviceInstallState.InstallStateInstalled;
                }
                return (DeviceInstallState)o;
            }
        }

        public uint NumaNode
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_Numa_Node");
                if (o == null)
                {
                    return 0u;
                }
                return (uint)o;
            }
        }

        public uint UINumber
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_UINumber");
                if (o == null)
                {
                    return 0u;
                }
                return (uint)o;
            }
        }

        public DeviceCharacteristics Characteristics
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_Characteristics");
                if (o == null)
                {
                    return 0u;
                }
                return (DeviceCharacteristics)o;
            }
        }

        public string Manufacturer
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_Manufacturer");
            }
        }

        public string[] HardwareIds
        {
            get
            {
                return (string[])GetProperty("DEVPKEY_Device_HardwareIds");
            }
        }

        public string[] LocationPaths
        {
            get
            {
                return (string[])GetProperty("DEVPKEY_Device_LocationPaths");
            }
        }

        public string DriverVersion
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_DriverVersion");
            }
        }

        public string DriverProvider
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_DriverProvider");
            }
        }

        public string DriverDescription
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_DriverDesc");
            }
        }

        public string LocationInfo
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_LocationInfo");
            }
        }

        public string InstanceId
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_InstanceId");
            }
        }

        public string Service
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_Service");
            }
        }

        public string DeviceParent
        {
            get
            {
                return (string)GetProperty("DEVPKEY_Device_Parent");
            }
        }

        public string[] DeviceSiblings
        {
            get
            {
                return (string[])GetProperty("DEVPKEY_Device_Siblings");
            }
        }

        public bool IsPresent
        {
            get
            {
                bool value = false;
                try
                {
                    value = (bool)GetProperty("DEVPKEY_Device_IsPresent");
                }
                catch
                {
                    value = !((NodeStatus & DNFlags.NO_SHOW_IN_DM) == DNFlags.NO_SHOW_IN_DM);
                }

                return value;
            }
        }

        public bool IsEnabled
        {
            get
            {
                return !((ProblemCode & CM_PROB.DISABLED) == CM_PROB.DISABLED);
            }
        }

        public bool HasProblem
        {
            get
            {
                try
                {
                    return (bool)GetProperty("DEVPKEY_Device_HasProblem");
                }
                catch
                {
                    return Convert.ToBoolean(ProblemCode);
                }
            }
        }

        public DNFlags NodeStatus
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_DevNodeStatus");
                if (o == null)
                {
                    return 0u;
                }
                return (DNFlags)(uint)o;
            }
        }

        public CM_PROB ProblemCode
        {
            get
            {
                object o = GetProperty("DEVPKEY_Device_ProblemCode");
                if (o == null)
                {
                    return 0u;
                }
                return (CM_PROB)(uint)o;
            }
        }

        public DeviceClass @Class
        {
            get
            {
                return (DeviceClass)DeviceClassGuids.ToList().IndexOf(classGuid);
            }
        }

        public Dictionary<string, object> AvailableProperties
        {
            get
            {
                Dictionary<string, object> props = new Dictionary<string, object>();
                foreach (string propertyName in DEVPKEY.Keys)
                {
                    DEVPROPKEY prop;
                    DEVPKEY.TryGetValue(propertyName, out prop);
                    object o;
                    if (Properties.TryGetValue(prop, out o))
                    {
                        props.Add(propertyName, o);
                    }
                }
                return props;
            }
        }

        private object GetProperty(string propertyName)
        {
            DEVPROPKEY prop;
            DEVPKEY.TryGetValue(propertyName, out prop);

            object o;
            Properties.TryGetValue(prop, out o);

            return o;
        }

        public override string ToString()
        {
            return Name;
        }
    }
}