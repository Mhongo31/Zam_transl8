# Deploy Flutter Web to Vercel

## 1) Build Flutter Web
```bash
cd zam_trans_app
flutter build web --release --no-wasm-dry-run
```

## 2) Deploy via Vercel Dashboard
- Go to https://vercel.com
- New Project → Import from GitHub
- Select your repo
- Framework: Other
- Output Directory: `zam_trans_app/build/web`
- Build Command: (leave empty)
- Install Command: (leave empty)
- Deploy

## 3) Deploy via Vercel CLI (alternative)
```bash
npm i -g vercel
cd zam_trans_app
vercel --prod
# Follow prompts:
# - Set up and deploy? Y
# - Which scope? (your account)
# - Link to existing project? N
# - Project name: zam-transl8
# - Directory: ./
# - Override settings? N
# - Build command: flutter build web --release --no-wasm-dry-run
# - Output directory: build/web
# - Install command: (empty)
# - Development command: (empty)
```

## 4) Set Environment Variables (if needed)
- In Vercel dashboard: Project → Settings → Environment Variables
- Add: `API_BASE_URL` = `https://your-api-host.com` (when you deploy the API)

## 5) Update API Base URL (after API is deployed)
- In Vercel dashboard: Project → Settings → Environment Variables
- Add: `API_BASE_URL` = `https://your-api-host.com`
- Redeploy

## 6) Test
- Visit your Vercel URL
- Try translating text
- Check Supabase for logged translations
