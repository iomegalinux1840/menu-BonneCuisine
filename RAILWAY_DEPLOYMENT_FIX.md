# Railway Deployment Fix - Menu BonneCuisine

## Issue Analysis
The Railway deployment is failing with HTTP 502 errors due to multiple configuration issues.

## Root Causes Identified

### 1. Asset Precompilation Errors
- **Problem**: Missing JavaScript assets in manifest.js causing Rails to fail when serving pages
- **Error**: `Asset 'application.js' was not declared to be precompiled in production`
- **Fixed**: Updated `app/assets/config/manifest.js` to properly link JavaScript assets

### 2. Missing Controllers Directory
- **Problem**: Stimulus controllers directory was missing in assets/javascripts
- **Fixed**: Created `app/assets/javascripts/controllers/application.js`

### 3. Environment Variables Required
The following environment variables must be set in Railway:

```bash
# Required for Rails production
SECRET_KEY_BASE=<generate with: rails secret>
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Database Configuration (PostgreSQL)
DATABASE_URL=<automatically provided by Railway PostgreSQL service>

# Port Configuration
PORT=<provided by Railway>
```

## Files Modified

### 1. app/assets/config/manifest.js
```javascript
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link application.js
//= link menu_updates.js
//= link controllers/application.js
```

### 2. Created: app/assets/javascripts/controllers/application.js
```javascript
// Controllers application.js
```

## Deployment Checklist

### Before Deployment
- [x] Fix asset precompilation issues
- [x] Create missing JavaScript directories
- [x] Test asset precompilation locally
- [ ] Set environment variables in Railway dashboard
- [ ] Ensure PostgreSQL service is linked

### Railway Environment Variables Setup

1. Go to Railway Dashboard
2. Select your project (ID: 5413f196-0656-4537-b4e0-6edcb5348175)
3. Navigate to Variables section
4. Add the following:

```bash
# Generate a new secret key
rails secret
# Copy the output and set as SECRET_KEY_BASE

SECRET_KEY_BASE=<paste generated key here>
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

### Verify PostgreSQL Connection
1. Ensure PostgreSQL service is deployed in Railway
2. DATABASE_URL should be automatically set when linked
3. Check that migrations run successfully during deployment

## Testing Commands

### Local Production Test
```bash
# Test asset precompilation
SECRET_KEY_BASE=test123 RAILS_ENV=production bundle exec rails assets:precompile

# Test server startup
SECRET_KEY_BASE=test123 RAILS_ENV=production bundle exec rails server
```

### After Deployment
```bash
# Check deployment status
./check_deployment.sh

# Monitor logs (if Railway CLI is authenticated)
railway logs -s <service-id>
```

## Common Issues & Solutions

### Issue: Assets not loading
**Solution**: Ensure `RAILS_SERVE_STATIC_FILES=true` is set

### Issue: Database connection failed
**Solution**: Verify DATABASE_URL is set and PostgreSQL service is running

### Issue: Secret key base error
**Solution**: Generate and set SECRET_KEY_BASE using `rails secret`

### Issue: Application crashes on startup
**Solution**: Check logs for missing gems or configuration issues

## Next Steps

1. Commit the changes to Git:
```bash
git add .
git commit -m "Fix asset precompilation for Railway deployment"
git push origin main
```

2. Set environment variables in Railway dashboard

3. Trigger a new deployment in Railway

4. Monitor deployment logs for any errors

5. Once deployed, verify the application at:
   https://menu-bonnecuisine-production.up.railway.app/

## Support Resources
- Railway Documentation: https://docs.railway.app/
- Rails Production Guide: https://guides.rubyonrails.org/configuring.html
- Asset Pipeline Guide: https://guides.rubyonrails.org/asset_pipeline.html