# H&P Express Inc. Website

A responsive, highly professional informational website for H&P Express Inc., built using Dart & Flutter Web. The site is optimized for performance, accessibility, and visual aesthetics, and can be hosted completely for free on Cloudflare Pages.

---

## Getting Started

Because `flutter` and `git` may not be registered globally on your system path, you should append their paths to your terminal environment variables before running any commands.

## Development & Run Locally

To test the website locally inside your Chrome browser:
```powershell
# Get package dependencies
flutter pub get

# Run the local development server in Google Chrome
flutter run -d chrome
```

---

## Compilation (Production Build)

To compile the optimized, release-ready static HTML, JS, and CSS files:
```powershell
flutter build web --release
```

The output bundle is generated inside the directory:
📂 `build/web/`

---

## Deployment (Cloudflare Pages)

To host your site for free:
1. Log in to the [Cloudflare Pages Dashboard](https://dash.cloudflare.com/).
2. Select **Pages** > **Create a project** > **Upload assets**.
3. Drag and drop the compiled `build/web/` directory.
4. Deploy! Your site will be online instantly.

---

## Configuration & Customization

All primary configurations, text copy, and secure contact detail encodings are centralized. You do not need to hunt through UI code to make basic edits:
*   [lib/config.dart](file:///c:/Workspace/HPExpressInc/lib/config.dart): Easily customize the Cognito Form embed script (under `cognitoFormEmbedHtml`) and update the secure phone/email contact details.
*   [lib/theme.dart](file:///c:/Workspace/HPExpressInc/lib/theme.dart): Modify the brand colors and font sizes.
