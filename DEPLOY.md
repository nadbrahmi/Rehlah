# Rehlah — Deploy Instructions

## Folder structure
```
docs/
  index.html        ← marketing page (NEVER touch this)
  app/
    index.html      ← Flutter app
    main.dart.js
    flutter.js
    ...
```

## URLs
- Marketing page: https://nadbrahmi.github.io/Rehlah/
- Flutter app:    https://nadbrahmi.github.io/Rehlah/app/

---

## Deploy workflow (every time)

```
flutter build web --release --base-href "/Rehlah/app/"
xcopy /E /I /Y build\web\* docs\app\
git add -A
git commit -m "Deploy: describe what changed"
git push
```

## ⚠️ Never run
```
rmdir /S /Q docs
```
This would delete the marketing page at `docs\index.html`.

---

## Branch workflow
- All new work → `testing` branch
- Test locally with `flutter run -d chrome`
- Once confirmed working:
  ```
  git add -A
  git commit -m "describe the feature"
  git push
  ```
- Merge to main when ready:
  ```
  git checkout main
  git merge testing
  git push
  ```
- Then deploy (see above)

---

## Backup tag
- `v1.0-working` — stable snapshot, always available
- Restore: `git checkout v1.0-working`
