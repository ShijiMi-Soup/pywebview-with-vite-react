# Hot Reload Implementation Plan

## Problem Statement
Currently, when running `npm run start` in dev mode:
1. Frontend is built statically to `../gui/` directory
2. Python backend loads the static `../gui/index.html` 
3. Any frontend changes require rebuilding and restarting the entire application
4. This creates a slow development cycle with no hot module replacement (HMR)

## How Typical Projects Implement Hot Reload

### 1. **Vite Dev Server + Proxy Pattern**
Most modern Vite-based desktop apps use:
- Vite dev server running on localhost:5173 (provides HMR out of the box)
- Desktop wrapper (Electron/Tauri/pywebview) loads from localhost:5173 in dev mode
- Production builds still use static files

**Examples:**
- Tauri: Uses `devPath` config to point to dev server in dev mode
- Electron-vite: Similar pattern with conditional URL loading
- pywebview projects often use environment variables to switch between dev/prod URLs

### 2. **File Watching + Auto Reload**
Alternative approach:
- Watch frontend source files for changes
- Trigger rebuild on change
- Reload webview window programmatically
- Less efficient than Vite HMR but simpler to implement

### 3. **WebSocket-based Live Reload**
Some projects use:
- WebSocket connection between frontend and backend
- Backend watches files and signals frontend to reload
- Frontend reconnects and refreshes on signal

## Recommended Implementation Approach

### **Option 1: Vite Dev Server Integration (Recommended)**

#### Advantages:
- ✅ Uses Vite's built-in HMR (Hot Module Replacement)
- ✅ Instant updates without full page reload
- ✅ Preserves React component state where possible
- ✅ Best developer experience
- ✅ Standard pattern used by modern frameworks
- ✅ No additional dependencies needed

#### Implementation Steps:

1. **Add dev mode detection in backend/index.py**
   - Check for environment variable or command line flag
   - Use `http://localhost:5173` in dev mode
   - Use `../gui/index.html` in production mode

2. **Update package.json scripts**
   - Add new `start:dev` script that:
     - Starts Vite dev server in background (frontend)
     - Waits for server to be ready
     - Starts Python backend pointing to dev server
   - Keep `start` as production mode (current behavior)

3. **Configure CORS if needed**
   - Vite dev server should allow pywebview to access it
   - Usually works by default but may need configuration

4. **Update documentation**
   - Document new dev mode usage
   - Explain difference between `npm run dev` (frontend only) and `npm run start:dev` (full app with HMR)

#### Code Changes Required:

**backend/index.py:**
```python
import os
import sys

def get_entrypoint():
    # Check if running in dev mode
    if '--dev' in sys.argv or os.environ.get('PYWEBVIEW_DEV') == '1':
        return 'http://localhost:5173'
    
    # Existing production mode logic
    def exists(path):
        return os.path.exists(os.path.join(os.path.dirname(__file__), path))
    
    if exists("../gui/index.html"):
        return "../gui/index.html"
    # ... rest of existing code
```

**package.json** (root):
```json
{
  "scripts": {
    "start:dev": "run-script-os",
    "start:dev:default": "npm run start-dev-server & sleep 3 && PYWEBVIEW_DEV=1 ./venv/bin/python backend/index.py --dev",
    "start:dev:windows": "start /B npm run start-dev-server && timeout /t 3 && set PYWEBVIEW_DEV=1 && .\\venv\\Scripts\\python backend\\index.py --dev",
    "start-dev-server": "cd frontend && npm run dev"
  }
}
```

### **Option 2: Watch + Reload Pattern**

#### Advantages:
- ✅ Simpler implementation
- ✅ No need to run dev server separately
- ✅ Works well for small projects

#### Disadvantages:
- ❌ Full page reload on every change
- ❌ Loses React component state
- ❌ Slower than HMR
- ❌ Requires additional file watching library

#### Implementation:
- Use `watchdog` Python library to watch frontend/src
- Trigger `npm run build-frontend` on changes
- Reload webview window via `window.reload()`

### **Option 3: Hybrid Approach**

Use Vite dev server for frontend development but add a Python file watcher for backend changes:
- Frontend: Vite HMR via localhost:5173
- Backend: Watch backend/*.py files and restart Python process

## Final Recommendation

**Implement Option 1 (Vite Dev Server Integration)** because:
1. Best developer experience with instant HMR
2. No additional Python dependencies
3. Follows industry standard patterns
4. Minimal code changes required
5. Clean separation between dev and production modes
6. Leverages Vite's powerful HMR capabilities

## Implementation Checklist

- [ ] Modify `backend/index.py` to support dev mode URL
- [ ] Add `--dev` flag support in backend
- [ ] Create `start:dev` and `start-dev-server` scripts in package.json
- [ ] Add cross-platform support (Windows/macOS/Linux)
- [ ] Test hot reload functionality with frontend changes
- [ ] Update README.md with new dev mode instructions
- [ ] Verify production build still works correctly
- [ ] Test that API communication works with dev server

## Testing Strategy

1. **Manual Testing:**
   - Start app in dev mode: `npm run start:dev`
   - Make changes to React components
   - Verify changes appear instantly without restart
   - Test pywebview API calls (save_content, fullscreen, etc.)
   - Verify ticker still updates from backend

2. **Production Mode Verification:**
   - Run `npm run start` (existing script)
   - Verify it still builds and runs correctly
   - Ensure no dev server dependencies in production

3. **Cross-platform Testing:**
   - Test on macOS and Windows
   - Verify scripts work on both platforms

## Potential Issues & Solutions

### Issue 1: Vite dev server not ready when Python starts
**Solution:** Add delay or health check before starting Python backend

### Issue 2: CORS errors from dev server
**Solution:** Configure Vite server options in vite.config.ts if needed

### Issue 3: WebSocket connection issues
**Solution:** Vite's HMR uses WebSocket - ensure pywebview allows WebSocket connections (usually works by default)

### Issue 4: pywebview.api not available in dev mode
**Solution:** Ensure js_api is registered before window creation, same as production

## Future Enhancements

- Add backend hot reload for Python file changes
- Implement auto-restart of Python process on backend changes
- Add configuration file for dev/prod settings
- Create GUI indicator showing dev/prod mode
