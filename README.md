# HerCare App (Frontend)

Flutter frontend for the HerCare women's health tracking app.

## Web Deployment (GitHub Pages)
This app is configured to automatically deploy to GitHub Pages using GitHub Actions.

### How to Deploy
1. Create a repository named `hercare-app` on GitHub.
2. Push this code to the `main` branch.
3. The GitHub Action will automatically:
   - Build the Flutter web app
   - Deploy it to the `gh-pages` branch
   - Your site will be live at `https://<YOUR_USERNAME>.github.io/hercare-app/`

### Configuration
- Base URL for backend is configured in `lib/services/api_service.dart`.
- GitHub Action workflow is in `.github/workflows/deploy.yml`.

## Local Development
```bash
flutter run -d chrome
```
