using DeviceManagementLib.Win32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;

namespace DeviceManagementLib
{
    public class DeviceManagementLib
    {
        private const int MAX_CLASS_NAME_LEN = 32;

        private static SP_DEVINFO_DATA[] GetDeviceInfoData(SafeDeviceInfoSetHandle handle)
        {
            List<SP_DEVINFO_DATA> data = new List<SP_DEVINFO_DATA>();
            SP_DEVINFO_DATA did = new SP_DEVINFO_DATA();
            int didSize = Marshal.SizeOf(did);
            did.Size = didSize;
            int index = 0;
            while (NativeMethods.SetupDiEnumDeviceInfo(handle, index, ref did))
            {
                data.Add(did);
                index += 1;
                did = new SP_DEVINFO_DATA();
                did.Size = didSize;
            }
            return data.ToArray();
        }

        // Find the index of the particular DeviceInfoData for the instanceId.
        private static int GetIndexOfInstance(SafeDeviceInfoSetHandle handle, SP_DEVINFO_DATA[] diData, string instanceId)
        {
            const int ERROR_INSUFFICIENT_BUFFER = 122;
            for (int index = 0; index <= diData.Length - 1; index++)
            {
                StringBuilder sb = new StringBuilder(1);
                int requiredSize = 0;
                bool result = NativeMethods.SetupDiGetDeviceInstanceId(handle.DangerousGetHandle(), ref diData[index], sb, sb.Capacity, out requiredSize);
                if (result == false && Marshal.GetLastWin32Error() == ERROR_INSUFFICIENT_BUFFER)
                {
                    sb.Capacity = requiredSize;
                    result = NativeMethods.SetupDiGetDeviceInstanceId(handle.DangerousGetHandle(), ref diData[index], sb, sb.Capacity, out requiredSize);
                }
                if (result == false)
                    throw new Win32Exception();
                if (instanceId.Equals(sb.ToString()))
                {
                    return index;
                }
            }
            // not found
            return -1;
        }

        public static IEnumerable<Device> GetDevices(string instanceId = "", DeviceClass? deviceClass = null)
        {
            SafeDeviceInfoSetHandle diSetHandle = null;
            try
            {
                GCHandle guid = new GCHandle();

                if (deviceClass.HasValue)
                {
                    var classGuid = Device.DeviceClassGuids[(int)deviceClass];
                    guid = GCHandle.Alloc(classGuid, GCHandleType.Pinned);
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(guid.AddrOfPinnedObject(), null, IntPtr.Zero, SetupDiGetClassDevsFlags.Null);
                }
                else
                {
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(IntPtr.Zero, null, IntPtr.Zero, SetupDiGetClassDevsFlags.AllClasses);
                }

                if (diSetHandle.IsInvalid)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling SetupDiGetClassDevs");
                }

                //Get the device information data for each matching device.
                var diData = GetDeviceInfoData(diSetHandle);

                if (!string.IsNullOrEmpty(instanceId))
                {
                    // Find the index of of the instance
                    int index = GetIndexOfInstance(diSetHandle, diData, instanceId);
                    if (index == -1)
                    {
                        throw new IndexOutOfRangeException(string.Format("The device '{0}' could not be found", instanceId));
                    }

                    diData = new SP_DEVINFO_DATA[] { diData[index] };
                }

                for (int i = 0; i < diData.Length; i++)
                {
                    uint propertyCount = 0;

                    if (!NativeMethods.SetupDiGetDevicePropertyKeys(diSetHandle, ref diData[i], IntPtr.Zero, 0, ref propertyCount, 0))
                    {
                        var error = Marshal.GetLastWin32Error();
                        if (error != 122)
                            throw new Win32Exception(error, "Error calling SetupDiGetDevicePropertyKeys");
                    }

                    var device = new Device(diData[i].ClassGuid);

                    DEVPROPKEY[] dev = new DEVPROPKEY[propertyCount];
                    GCHandle devPropHandle = GCHandle.Alloc(dev, GCHandleType.Pinned);

                    if (!NativeMethods.SetupDiGetDevicePropertyKeys(diSetHandle, ref diData[i], devPropHandle.AddrOfPinnedObject(), (uint)dev.Length, ref propertyCount, 0))
                    {
                        var error = Marshal.GetLastWin32Error();
                        throw new Win32Exception(error, "Error calling SetupDiGetDevicePropertyKeys");
                    }

                    int devicePropertyIterator = 0;
                    while (devicePropertyIterator < propertyCount)
                    {
                        byte[] propBuffer = new byte[1];
                        uint requiredSize = 0;

                        DEVPROPTYPE devicePropertyType;
                        if (!NativeMethods.SetupDiGetDeviceProperty(
                            diSetHandle,
                            ref diData[i],
                            ref dev[devicePropertyIterator],
                            out devicePropertyType, propBuffer,
                            (uint)propBuffer.Length,
                            ref requiredSize,
                            0))
                        {
                            var error = Marshal.GetLastWin32Error();
                            if (error != 122)
                                throw new Win32Exception(error, "Error calling SetupDiGetDeviceProperty");
                        }

                        Array.Resize(ref propBuffer, (int)requiredSize);

                        if (NativeMethods.SetupDiGetDeviceProperty(diSetHandle, ref diData[i], ref dev[devicePropertyIterator], out devicePropertyType, propBuffer, (uint)propBuffer.Length, ref requiredSize, 0))
                        {
                            DEVPROPTYPE devPropType = devicePropertyType;
                            switch (devPropType)
                            {
                                case DEVPROPTYPE.DEVPROP_TYPE_UINT16:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToUInt16(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_INT32:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToInt32(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_UINT32:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToUInt32(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_INT64:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToInt64(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_FLOAT:
                                case DEVPROPTYPE.DEVPROP_TYPE_DOUBLE:
                                case DEVPROPTYPE.DEVPROP_TYPE_DECIMAL:
                                case DEVPROPTYPE.DEVPROP_TYPE_CURRENCY:
                                case DEVPROPTYPE.DEVPROP_TYPE_DATE:
                                    throw new Exception(string.Format("No property processing available for device property type '{0}'", devPropType.ToString()));

                                case DEVPROPTYPE.DEVPROP_TYPE_UINT64:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToUInt64(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_GUID:
                                    {
                                        byte[] guidBuffer = new byte[16];
                                        Array.ConstrainedCopy(propBuffer, 0, guidBuffer, 0, 16);
                                        device.Properties.Add(dev[devicePropertyIterator], new Guid(guidBuffer));
                                        break;
                                    }
                                case DEVPROPTYPE.DEVPROP_TYPE_FILETIME:
                                    device.Properties.Add(dev[devicePropertyIterator], DateTime.FromFileTime(BitConverter.ToInt64(propBuffer, 0)));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_BOOLEAN:
                                    device.Properties.Add(dev[devicePropertyIterator], BitConverter.ToBoolean(propBuffer, 0));
                                    break;

                                case DEVPROPTYPE.DEVPROP_TYPE_STRING:
                                    var value = Encoding.Unicode.GetString(propBuffer, 0, (int)requiredSize);
                                    if (value[value.Length - 1] == (new char[1])[0])
                                    {
                                        value = value.Substring(0, value.Length - 1);
                                    }
                                    device.Properties.Add(dev[devicePropertyIterator], value);

                                    break;

                                default:
                                    {
                                        Dictionary<DEVPROPKEY, object> properties = device.Properties;
                                        DEVPROPKEY prop = dev[devicePropertyIterator];
                                        string propValue = Encoding.Unicode.GetString(propBuffer, 0, (int)requiredSize);
                                        char[] separator = new char[1];
                                        properties.Add(prop, propValue.Split(separator));
                                        break;
                                    }
                            }

                            devicePropertyIterator++;
                        }
                    }

                    devPropHandle.Free();
                    yield return device;
                }

                diSetHandle.Close();
            }
            finally
            {
                if (diSetHandle != null)
                {
                    if (diSetHandle.IsClosed == false)
                    {
                        diSetHandle.Close();
                    }
                    diSetHandle.Dispose();
                }
            }
        }

        public static void RemoveDevice(string instanceId, DeviceClass? deviceClass = null)
        {
            SafeDeviceInfoSetHandle diSetHandle = null;
            try
            {
                GCHandle guid = new GCHandle();

                if (deviceClass.HasValue)
                {
                    var classGuid = Device.DeviceClassGuids[(int)deviceClass];
                    guid = GCHandle.Alloc(classGuid, GCHandleType.Pinned);
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(guid.AddrOfPinnedObject(), null, IntPtr.Zero, SetupDiGetClassDevsFlags.Null);
                }
                else
                {
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(IntPtr.Zero, null, IntPtr.Zero, SetupDiGetClassDevsFlags.AllClasses);
                }

                if (diSetHandle.IsInvalid)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling SetupDiGetClassDevs");
                }

                //Get the device information data for each matching device.
                var diData = GetDeviceInfoData(diSetHandle);

                if (!string.IsNullOrEmpty(instanceId))
                {
                    // Find the index of of the instance
                    int index = GetIndexOfInstance(diSetHandle, diData, instanceId);
                    if (index == -1)
                    {
                        throw new IndexOutOfRangeException(string.Format("The device '{0}' could not be found", instanceId));
                    }

                    diData = new SP_DEVINFO_DATA[] { diData[index] };
                }

                for (int i = 0; i < diData.Length; i++)
                {
                    var needReboot = false;
                    var result = NativeMethods.DiUninstallDevice(IntPtr.Zero, diSetHandle.DangerousGetHandle(), ref diData[i], 0, out needReboot);

                    if (result == false)
                    {
                        int err = Marshal.GetLastWin32Error();
                        throw new Win32Exception();
                    }
                }
            }
            finally
            {
                if (diSetHandle != null)
                {
                    if (diSetHandle.IsClosed == false)
                    {
                        diSetHandle.Close();
                    }
                    diSetHandle.Dispose();
                }
            }
        }

        public static void SetDeviceState(string instanceId, DICS state, DeviceClass? deviceClass = null)
        {
            SafeDeviceInfoSetHandle diSetHandle = null;
            try
            {
                GCHandle guid = new GCHandle();

                if (deviceClass.HasValue)
                {
                    var classGuid = Device.DeviceClassGuids[(int)deviceClass];
                    guid = GCHandle.Alloc(classGuid, GCHandleType.Pinned);
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(guid.AddrOfPinnedObject(), null, IntPtr.Zero, SetupDiGetClassDevsFlags.Null);
                }
                else
                {
                    diSetHandle = NativeMethods.SetupDiGetClassDevs(IntPtr.Zero, null, IntPtr.Zero, SetupDiGetClassDevsFlags.AllClasses);
                }

                if (diSetHandle.IsInvalid)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling SetupDiGetClassDevs");
                }

                //Get the device information data for each matching device.
                var diData = GetDeviceInfoData(diSetHandle);

                if (!string.IsNullOrEmpty(instanceId))
                {
                    // Find the index of of the instance
                    int index = GetIndexOfInstance(diSetHandle, diData, instanceId);
                    if (index == -1)
                    {
                        throw new IndexOutOfRangeException(string.Format("The device '{0}' could not be found", instanceId));
                    }

                    diData = new SP_DEVINFO_DATA[] { diData[index] };
                }

                for (int i = 0; i < diData.Length; i++)
                {
                    SP_CLASSINSTALL_HEADER installHeader = default(SP_CLASSINSTALL_HEADER);
                    installHeader.InstallFunction = DIF.DIF_PROPERTYCHANGE;
                    installHeader.cbSize = (uint)Marshal.SizeOf(installHeader);

                    SP_PROPCHANGE_PARAMS propertyChangeParameters = default(SP_PROPCHANGE_PARAMS);
                    propertyChangeParameters.ClassInstallHeader = installHeader;
                    propertyChangeParameters.HwProfile = 0;
                    propertyChangeParameters.Scope = DICS.DICS_FLAG_CONFIGSPECIFIC;
                    propertyChangeParameters.StateChange = state;
                    if (NativeMethods.SetupDiSetClassInstallParams(diSetHandle, ref diData[i], ref propertyChangeParameters, (uint)Marshal.SizeOf(propertyChangeParameters)))
                    {
                        if (!NativeMethods.SetupDiCallClassInstaller(DIF.DIF_PROPERTYCHANGE, diSetHandle, ref diData[i]))
                        {
                            throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling SetupDiCallClassInstaller");
                        }
                    }
                }
            }
            finally
            {
                if (diSetHandle != null)
                {
                    if (diSetHandle.IsClosed == false)
                    {
                        diSetHandle.Close();
                    }
                    diSetHandle.Dispose();
                }
            }
        }

        public static void HookHardwareNotifications(IntPtr callback, bool UseWindowHandle)
        {
            try
            {
                DEV_BROADCAST_DEVICEINTERFACE dbdi = new DEV_BROADCAST_DEVICEINTERFACE();
                dbdi.dbcc_size = (uint)Marshal.SizeOf(dbdi);
                dbdi.dbcc_reserved = 0;
                dbdi.dbcc_devicetype = (uint)DBT_DEVTYP.DBT_DEVTYP_DEVICEINTERFACE;
                if (UseWindowHandle)
                {
                    NativeMethods.RegisterDeviceNotification(
                        callback,
                        dbdi,
                        DEVICE_NOTIFY.DEVICE_NOTIFY_ALL_INTERFACE_CLASSES | DEVICE_NOTIFY.DEVICE_NOTIFY_WINDOW_HANDLE);
                }
                else
                {
                    NativeMethods.RegisterDeviceNotification(
                        callback,
                        dbdi,
                        DEVICE_NOTIFY.DEVICE_NOTIFY_ALL_INTERFACE_CLASSES | DEVICE_NOTIFY.DEVICE_NOTIFY_WINDOW_HANDLE);
                }
            }
            catch (Exception ex)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling RegisterDeviceNotification");
            }
        }

        public static void CutLooseHardwareNotifications(IntPtr callback)
        {
            uint result = 0;

            result = NativeMethods.UnregisterDeviceNotification(callback);

            if (result != 0)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Error calling UnregisterDeviceNotification");
            }
        }
    }
}