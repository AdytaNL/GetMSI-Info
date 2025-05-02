# GetMSI-Info.ps1

This PowerShell script allows you to extract metadata from `.msi` installer files, including:

- `ProductCode`
- `ProductVersion`
- `ProductName`
- `Manufacturer`

It logs the results to both the console and a log file. Useful for software deployment validation, automation, and documentation.

---

## ⚠️ Disclaimer

> This script was developed for internal use. You are free to use or adapt it under the license below, but:
>
> - It is **not actively maintained**
> - **No support** is provided
> - Use at your own risk

Feel free to submit pull requests if you find ways to improve it — but please understand there is no guarantee of response.

---

## 🔧 Features

- GUI-based file picker (optional)
- Command-line support for automation
- Detailed logging to file and console
- Clean COM object handling
- Supports silent mode (`-Silent`)

---

## 🚀 Usage

### Interactive Mode (GUI)

```powershell
.\GetMSI-Info.ps1
```

You will be prompted to select an MSI file using a file dialog.

### Silent Mode (No GUI)

```powershell
.\GetMSI-Info.ps1 -MSIPath "C:\Path\To\YourFile.msi" -Silent
```

This is ideal for automated scripts, CI/CD, or remote usage.

---

## ⚙ Parameters

| Parameter  | Description                                                  | Required |
|------------|--------------------------------------------------------------|----------|
| `-MSIPath` | Full path to the MSI file                                    | Yes (if `-Silent` is used) |
| `-LogPath` | Custom log output folder (default: `C:\Install\Scripts\Logs`) | No       |
| `-Silent`  | Suppresses the GUI and requires `-MSIPath`                   | No       |

---

## 📁 Log Output

Logs are written to a `.log` file named after the script itself, for example:

```
C:\Install\Scripts\Logs\GetMSI-Info.log
```

Log entries include timestamp, severity, username, and the message.

---

## 📦 Requirements

- Windows with PowerShell
- Windows Installer (COM object)
- GUI only required for interactive mode

---

## 👤 Author

Lambert

---

## 📄 License

This project is licensed under the MIT License.
