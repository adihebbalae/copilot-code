"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkForUpdates = checkForUpdates;
const vscode = __importStar(require("vscode"));
const https = __importStar(require("node:https"));
const REPO = 'adihebbalae/Attacca';
const VERSION_URL = `https://raw.githubusercontent.com/${REPO}/master/.github/BOILERPLATE_VERSION`;
const CHANGELOG_URL = `https://raw.githubusercontent.com/${REPO}/master/CHANGELOG.md`;
async function checkForUpdates(extensionVersion) {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders || folders.length === 0) {
        vscode.window.showErrorMessage('Attacca: No workspace folder open.');
        return;
    }
    const root = folders[0].uri;
    // Read local version
    const localVersion = await readLocalVersion(root);
    if (!localVersion) {
        const action = await vscode.window.showInformationMessage('Attacca: No attacca.config.json found in this workspace. Initialize the project first.', 'Initialize');
        if (action === 'Initialize') {
            vscode.commands.executeCommand('attacca.init');
        }
        return;
    }
    await vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: 'Attacca: Checking for updates…',
        cancellable: false,
    }, async () => {
        let remoteVersion;
        try {
            remoteVersion = (await fetchText(VERSION_URL)).trim().split('\n')[0].trim();
        }
        catch {
            vscode.window.showWarningMessage('Attacca: Could not reach GitHub to check for updates. Check your network connection.');
            return;
        }
        const localSemver = parseSemver(localVersion.replace(/^v/, ''));
        const remoteSemver = parseSemver(remoteVersion.replace(/^v/, ''));
        if (!isNewer(remoteSemver, localSemver)) {
            vscode.window.showInformationMessage(`Attacca: You're up to date (${localVersion}).`);
            return;
        }
        // Fetch changelog excerpt
        let changelogExcerpt = '';
        try {
            const changelog = await fetchText(CHANGELOG_URL);
            changelogExcerpt = extractChangelogFor(changelog, remoteVersion);
        }
        catch {
            // Optional, ignore
        }
        const detail = changelogExcerpt
            ? `\n\nWhat's new in ${remoteVersion}:\n${changelogExcerpt}`
            : '';
        const action = await vscode.window.showInformationMessage(`Attacca: Update available — ${localVersion} → ${remoteVersion}.${detail}`, { modal: true }, 'Update Agent + Prompt Files', 'Skip');
        if (action !== 'Update Agent + Prompt Files') {
            return;
        }
        await applyUpdate(root, extensionVersion, remoteVersion, localVersion);
    });
}
async function applyUpdate(root, extensionVersion, remoteVersion, previousVersion) {
    // Files safe to overwrite on update (config / template files, not user state)
    const updateablePatterns = [
        '.github/agents/',
        '.github/prompts/',
        '.github/copilot-instructions.md',
        '.github/BOILERPLATE_VERSION',
        '.cursor/rules/',
        '.clinerules/',
        '.windsurfrules',
        'CLAUDE.md',
        'AGENTS.md',
        'GEMINI.md',
    ];
    // Read existing config to know which adapters were selected
    const configUri = vscode.Uri.joinPath(root, 'attacca.config.json');
    let config = null;
    try {
        const bytes = await vscode.workspace.fs.readFile(configUri);
        config = JSON.parse(Buffer.from(bytes).toString('utf8'));
    }
    catch {
        // No config — can't update intelligently
        vscode.window.showWarningMessage('Attacca: Could not read attacca.config.json. Run Re-initialize to do a full setup.');
        return;
    }
    // Import templates dynamically (same module, already loaded)
    const { getSharedFiles, getAdapterFiles } = await Promise.resolve().then(() => __importStar(require('./templates')));
    const opts = {
        fullAgents: config.agents === 'full',
        llmMode: config.llmMode,
    };
    let filesUpdated = 0;
    const write = async (relPath, content) => {
        const inUpdateableSet = updateablePatterns.some(p => relPath.startsWith(p) || relPath === p.replace(/\/$/, ''));
        if (!inUpdateableSet) {
            return;
        }
        const fileUri = vscode.Uri.joinPath(root, relPath);
        const dir = relPath.includes('/') ? relPath.split('/').slice(0, -1).join('/') : '';
        if (dir) {
            await vscode.workspace.fs.createDirectory(vscode.Uri.joinPath(root, dir));
        }
        await vscode.workspace.fs.writeFile(fileUri, Buffer.from(content, 'utf8'));
        filesUpdated++;
    };
    // Write shared files (only safe ones)
    const sharedFiles = getSharedFiles(opts);
    for (const [relPath, content] of Object.entries(sharedFiles)) {
        await write(relPath, content);
    }
    // Write adapter files for previously selected adapters
    for (const adapter of config.tools) {
        const files = getAdapterFiles(adapter, opts);
        for (const [relPath, content] of Object.entries(files)) {
            await write(relPath, content);
        }
    }
    // Update BOILERPLATE_VERSION
    await vscode.workspace.fs.writeFile(vscode.Uri.joinPath(root, '.github', 'BOILERPLATE_VERSION'), Buffer.from(`${remoteVersion}\n# Template: ${REPO}\n# Updated by Attacca extension from ${previousVersion}\n`, 'utf8'));
    // Update config version
    config.version = remoteVersion;
    await vscode.workspace.fs.writeFile(configUri, Buffer.from(JSON.stringify(config, null, 2) + '\n', 'utf8'));
    vscode.window.showInformationMessage(`✓ Attacca updated to ${remoteVersion} (${filesUpdated} files refreshed). State files and customizations were preserved.`);
}
// ─── Helpers ──────────────────────────────────────────────────────────
async function readLocalVersion(root) {
    // Try attacca.config.json first
    try {
        const bytes = await vscode.workspace.fs.readFile(vscode.Uri.joinPath(root, 'attacca.config.json'));
        const config = JSON.parse(Buffer.from(bytes).toString('utf8'));
        if (config.version) {
            return config.version;
        }
    }
    catch { /* fall through */ }
    // Try .github/BOILERPLATE_VERSION
    try {
        const bytes = await vscode.workspace.fs.readFile(vscode.Uri.joinPath(root, '.github', 'BOILERPLATE_VERSION'));
        return Buffer.from(bytes).toString('utf8').trim().split('\n')[0];
    }
    catch { /* fall through */ }
    return null;
}
function fetchText(url) {
    return new Promise((resolve, reject) => {
        const req = https.get(url, { timeout: 8000 }, (res) => {
            if (res.statusCode !== 200) {
                reject(new Error(`HTTP ${res.statusCode}`));
                return;
            }
            let data = '';
            res.on('data', (chunk) => { data += chunk.toString(); });
            res.on('end', () => resolve(data));
        });
        req.on('error', reject);
        req.on('timeout', () => { req.destroy(); reject(new Error('Request timed out')); });
    });
}
function parseSemver(v) {
    const [major = 0, minor = 0, patch = 0] = v.split('.').map(Number);
    return { major, minor, patch };
}
function isNewer(a, b) {
    if (a.major !== b.major) {
        return a.major > b.major;
    }
    if (a.minor !== b.minor) {
        return a.minor > b.minor;
    }
    return a.patch > b.patch;
}
function extractChangelogFor(changelog, version) {
    const lines = changelog.split('\n');
    const start = lines.findIndex(l => l.includes(version));
    if (start === -1) {
        return '';
    }
    // Grab up to 8 lines after the version header
    return lines
        .slice(start + 1, start + 9)
        .filter(l => l.trim() && !l.startsWith('##'))
        .map(l => l.replace(/^[-*]\s*/, '• '))
        .join('\n')
        .slice(0, 300);
}
//# sourceMappingURL=updater.js.map