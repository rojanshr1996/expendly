# Fastlane Android Setup for Firebase App Distribution

This setup automates building and distributing Expendly Android builds (`dev`, `qa`, `prod`) to Firebase App Distribution.

## 📋 Prerequisites

1. **Install Dependencies**:
   Navigate to the `android/` directory and install gems:
   ```bash
   cd android
   bundle install
   ```

2. **Authentication Options**:
   Choose one of the following authentication methods for Firebase:

   - **Method A: Service Account Key (Recommended for CI/CD)**:
     Download a GCP Service Account Key JSON with *Firebase App Distribution Admin* role and set the environment variable:
     ```bash
     export FIREBASE_SERVICE_ACCOUNT_KEY_PATH="/path/to/service-account-key.json"
     ```

   - **Method B: Firebase CLI Token**:
     Generate a CLI token via `npx -y firebase-tools@latest login:ci` and set the environment variable:
     ```bash
     export FIREBASE_CLI_TOKEN="your_firebase_cli_token"
     ```

---

## 🚀 Usage Commands

You can run Fastlane commands using `rps` or `bundle exec fastlane`:

### 1. DEV Flavor
- **RPS Command**: `rps distribute dev`
- **Fastlane Command**:
  ```bash
  cd android
  bundle exec fastlane distribute_dev groups:"dev-testers" release_notes:"Feature update"
  ```
- **Firebase App ID**: `1:748636232967:android:87bd73587100d5a126b9a2` (`com.expendly.app.dev`)

### 2. QA Flavor
- **RPS Command**: `rps distribute qa`
- **Fastlane Command**:
  ```bash
  cd android
  bundle exec fastlane distribute_qa groups:"qa-testers" release_notes:"QA Sprint build"
  ```
- **Firebase App ID**: `1:748636232967:android:d5c5362c2afc683726b9a2` (`com.expendly.app.qa`)

### 3. PROD Flavor
- **RPS Command**: `rps distribute prod`
- **Fastlane Command**:
  ```bash
  cd android
  bundle exec fastlane distribute_prod groups:"prod-testers" release_notes:"Production release candidate"
  ```
- **Firebase App ID**: `1:748636232967:android:b869f641ba48869026b9a2` (`com.expendly.app`)
