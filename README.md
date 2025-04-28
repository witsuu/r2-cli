# r2cli

[![Build Status](https://img.shields.io/github/actions/workflow/status/witsuu/r2cli/release.yml?branch=main)](https://github.com/witsuu/r2cli/actions)
[![Latest Release](https://img.shields.io/github/v/release/witsuu/r2cli)](https://github.com/witsuu/r2cli/releases)
[![License](https://img.shields.io/github/license/witsuu/r2cli)](LICENSE)

**r2cli** adalah **Command Line Interface (CLI)** sederhana untuk mengelola file di **Cloudflare R2 Storage**.  
Mudah digunakan untuk upload, download, konfigurasi akun, dan update binary dari GitHub Release terbaru.

---

## 📚 Table of Contents

- [Fitur](#-fitur)
- [Instalasi](#-instalasi)
- [Uninstall](#-uninstall)
- [Cara Penggunaan](#-cara-penggunaan)
- [Releases](#-releases)
- [Kontribusi](#-kontribusi)
- [Lisensi](#-lisensi)

---

## ✨ Fitur

- Upload file ke Cloudflare R2
- Download file dari Cloudflare R2
- Update otomatis ke versi terbaru
- Konfigurasi akses ke R2 via CLI
- Support Linux, macOS, dan Windows

---

## 📦 Instalasi

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/witsuu/r2cli/main/install.sh | bash
```

> Ganti `witsuu` dengan GitHub username kamu!

Atau manual:

```bash
git clone https://github.com/witsuu/r2cli.git
cd r2cli
bash install.sh
```

### Windows (Git Bash / WSL)

```bash
curl -fsSL https://raw.githubusercontent.com/witsuu/r2cli/main/install.sh | bash
```

> File binary akan diinstall ke `%USERPROFILE%\bin\r2cli.exe`.  
> PATH akan otomatis diupdate jika perlu.

---

## 🧹 Uninstall

### Linux / macOS

```bash
bash uninstall.sh
```

### Windows

```bash
bash uninstall.sh
```

Setelah uninstall, binary `r2cli` akan dihapus.  
Kalau install di Windows, PATH akan dibersihkan otomatis jika perlu.

---

## 🚀 Cara Penggunaan

### Konfigurasi Akun R2

```bash
r2cli configure
```

Masukkan:

- Access Key
- Secret Key
- Account ID

### Upload File ke R2

```bash
r2cli upload --bucket my-bucket --file path/to/local/file.txt --key remote/path/file.txt
```

### Download File dari R2

```bash
r2cli download --bucket my-bucket --key remote/path/file.txt --output path/to/save/file.txt
```

### Update r2cli ke Versi Terbaru

```bash
r2cli update
```

---

## 📸 Screenshot

![r2cli Screenshot](https://user-images.githubusercontent.com/your-github-id/your-image-id.png)

> Kamu bisa ganti URL gambar di atas setelah upload screenshot di GitHub issues atau image hosting.

---

## 🔖 Releases

Lihat semua versi yang tersedia di:

👉 [GitHub Releases](https://github.com/witsuu/r2cli/releases)

---

## 🤝 Kontribusi

Pull request dan issue sangat diterima! 🎉  
Feel free untuk membantu meningkatkan project ini.

---

## 📄 Lisensi

Project ini dirilis di bawah lisensi [MIT License](LICENSE).

---
