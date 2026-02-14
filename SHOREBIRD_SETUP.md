# Shorebird Setup (Code Push)

Shorebird is configured in this project. Complete these steps to start using OTA updates.

## What’s already done

- **`shorebird.yaml`** – Created with a placeholder `app_id` (must be replaced by `shorebird init`).
- **`pubspec.yaml`** – `shorebird.yaml` is included in `flutter.assets` so the updater can read it at runtime.
- **Android** – `INTERNET` permission is already present in `AndroidManifest.xml`.
- **Git** – `core.longpaths` is set to `true` for your user (recommended for Shorebird’s Flutter checkout).

## Steps you need to run

### 1. Use Shorebird CLI

Shorebird is installed under your user folder. Use one of these:

**Option A – Add to PATH (recommended)**  
Add this folder to your user PATH:

- `C:\Users\hamja\.shorebird\bin`

Then in a **new** terminal you can run `shorebird` from anywhere.

**Option B – Call by full path**

```powershell
& "$env:USERPROFILE\.shorebird\bin\shorebird.bat" <command>
```

### 2. Log in

```powershell
shorebird login
```

If you use the full path:

```powershell
& "$env:USERPROFILE\.shorebird\bin\shorebird.bat" login
```

Sign in at [console.shorebird.dev](https://console.shorebird.dev) if you don’t have an account.

### 3. Get your app ID (replace placeholder)

From the **project root** (`dynamic-ecommerce`):

```powershell
shorebird init --display-name "Kardosi"
```

This will:

- Register the app with Shorebird (if needed).
- Replace the placeholder `app_id` in `shorebird.yaml` with your real app ID.

You can commit the updated `shorebird.yaml` after this.

### 4. (Optional) Fix long path warnings

If you see “Filename too long” or “Git long paths” warnings and the install had issues, run (may require Administrator):

```powershell
git config --system core.longpaths true
```

### 5. Create a release (required before patches)

Build and register the first release so Shorebird knows which build to patch:

**Android:**

```powershell
shorebird release android
```

**iOS (on macOS with Xcode):**

```powershell
shorebird release ios
```

Use the produced artifacts for store submission (e.g. Play Store / App Store).

### 6. Push updates (patches)

After changing Dart/Flutter code and without submitting a new store build:

**Android:**

```powershell
shorebird patch android
```

**iOS:**

```powershell
shorebird patch ios
```

---

## After init: what to check before running the product

1. **Run doctor** (from project root):
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" doctor
   ```
   Fix any reported issues (Flutter, Android SDK, etc.).

2. **Confirm `shorebird.yaml`** has a real `app_id` (a UUID like `a1b2c3d4-...`), not `00000000-0000-0000-0000-000000000000`. If it’s still the placeholder, see “Fix placeholder app_id” below.

3. **Android:** INTERNET permission is already in your app; no change needed.

4. **Create the first release** before using the app with Shorebird or testing patches (see below). Patches apply only on top of a release.

---

## Fix placeholder app_id (still 00000000-0000-0000-0000-000000000000)

If `shorebird.yaml` still has `app_id: 00000000-0000-0000-0000-000000000000`, do this:

1. **Open PowerShell** and go to the project root:
   ```powershell
   cd c:\Users\hamja\StudioProjects\dynamic-ecommerce
   ```

2. **Log in** (if you aren’t already):
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" login
   ```
   Complete the browser sign-in.

3. **Run init** so Shorebird registers the app and writes the real `app_id` into `shorebird.yaml`:
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" init --display-name "Kardosi"
   ```
   When asked “How should we refer to this app?”, press Enter for “Kardosi” or type another name.

4. **Check** that `shorebird.yaml` now has a real UUID (e.g. `app_id: a1b2c3d4-e5f6-7890-abcd-ef1234567890`). Then you can create a release and use patches.

---

## Next process: first release, then run the product

1. **Create your first release** (required before patches work):
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" release android
   ```
   - Use the generated APK/AAB for Play Store or install it on a device/emulator for testing.
   - This build is the “base”; all patches are applied on top of it.

2. **Run the product:**
   - Install the release APK on a device/emulator, or use:
     ```powershell
     & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" preview
     ```
     to run a release build locally.

3. **Later:** When you change Dart/Flutter code and want to ship an OTA update:
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" patch android
   ```

---

## How to check that the patch is working

1. **Install the release** you built with `shorebird release android` (install the APK on a device or emulator). Open the app and note the current behavior (e.g. a label text or screen).

2. **Make a small, visible change** in your Dart code (e.g. in `lib/main.dart` or any screen):
   - Change a string (e.g. `'Welcome'` → `'Welcome (updated via patch)'`), or
   - Add a small widget (e.g. a `Text('Patched!')` at the top of a screen).

3. **Push a patch:**
   ```powershell
   & "$env:USERPROFILE\.shorebird\bin\shorebird.bat" patch android
   ```

4. **On the device/emulator:** Fully close the app (swipe away from recents), then open it again. The app will check for updates and apply the patch.

5. **Verify:** The visible change (new text or widget) should appear **without** reinstalling the APK. If you see the change after reopening the app, the patch is working.

**Optional – use preview to test:** You can also run `shorebird preview` to run a release or patch build locally without installing an APK manually.

---

## Quick reference

| Action              | Command                    |
|---------------------|----------------------------|
| Check setup         | `shorebird doctor`         |
| Log in              | `shorebird login`          |
| Register app / init | `shorebird init --display-name "Kardosi"` |
| First full release  | `shorebird release android` or `shorebird release ios` |
| OTA update          | `shorebird patch android` or `shorebird patch ios` |
| Preview build       | `shorebird preview`       |

---

## Docs

- [Shorebird – Getting started](https://docs.shorebird.dev/getting-started)
- [Initialize Shorebird](https://docs.shorebird.dev/code-push/initialize)
