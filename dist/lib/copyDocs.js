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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupCommand = setupCommand;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const chalk_1 = __importDefault(require("chalk"));
const inquirer_1 = __importDefault(require("inquirer"));
const packageRoot = path.resolve(__dirname, '../..');
const fileMappings = [
    {
        source: path.join(packageRoot, 'guild-docs/.guild'),
        destination: '.guild',
        isDirectory: true
    },
    {
        source: path.join(packageRoot, 'guild-docs/Setup/NewCLAUDE.md'),
        destination: 'CLAUDE.md',
        isDirectory: false
    },
    {
        source: path.join(packageRoot, 'guild-docs/Setup/.guild-config.example'),
        destination: '.guild-config',
        isDirectory: false
    }
];
function exists(filePath) {
    try {
        fs.accessSync(filePath);
        return true;
    }
    catch {
        return false;
    }
}
function copyFile(source, destination) {
    fs.copyFileSync(source, destination);
}
function copyDirectory(source, destination) {
    if (!fs.existsSync(destination)) {
        fs.mkdirSync(destination, { recursive: true });
    }
    const files = fs.readdirSync(source);
    files.forEach(file => {
        const sourcePath = path.join(source, file);
        const destPath = path.join(destination, file);
        const stats = fs.statSync(sourcePath);
        if (stats.isDirectory()) {
            copyDirectory(sourcePath, destPath);
        }
        else {
            copyFile(sourcePath, destPath);
        }
    });
}
function getFilesToCopy() {
    const files = [];
    fileMappings.forEach(mapping => {
        const destination = path.resolve(process.cwd(), mapping.destination);
        if (mapping.isDirectory) {
            const getAllFiles = (dir, baseDir) => {
                const dirFiles = fs.readdirSync(dir);
                dirFiles.forEach(file => {
                    const fullPath = path.join(dir, file);
                    const stats = fs.statSync(fullPath);
                    const relativePath = path.relative(baseDir, fullPath);
                    const destPath = path.join(destination, relativePath);
                    if (stats.isDirectory()) {
                        getAllFiles(fullPath, baseDir);
                    }
                    else {
                        files.push({
                            source: fullPath,
                            destination: destPath,
                            exists: exists(destPath)
                        });
                    }
                });
            };
            if (exists(mapping.source)) {
                getAllFiles(mapping.source, mapping.source);
            }
        }
        else {
            files.push({
                source: mapping.source,
                destination: destination,
                exists: exists(destination)
            });
        }
    });
    return files;
}
async function setupCommand(options) {
    console.log(chalk_1.default.blue('🏰 Guild Setup'));
    console.log();
    const filesToCopy = getFilesToCopy();
    const existingFiles = filesToCopy.filter(f => f.exists);
    if (options.dryRun) {
        console.log(chalk_1.default.yellow('DRY RUN MODE - No files will be copied'));
        console.log();
        console.log('The following operations would be performed:');
        console.log();
        filesToCopy.forEach(file => {
            const status = file.exists ? chalk_1.default.yellow('[OVERWRITE]') : chalk_1.default.green('[CREATE]');
            console.log(`${status} ${file.destination}`);
        });
        return;
    }
    if (existingFiles.length > 0) {
        console.log(chalk_1.default.yellow('⚠️  The following files already exist and will be overwritten:'));
        console.log();
        existingFiles.forEach(file => {
            console.log(`  - ${file.destination}`);
        });
        console.log();
        const { confirm } = await inquirer_1.default.prompt([
            {
                type: 'confirm',
                name: 'confirm',
                message: 'Do you want to proceed with overwriting these files?',
                default: false
            }
        ]);
        if (!confirm) {
            console.log(chalk_1.default.red('Setup cancelled.'));
            process.exit(0);
        }
    }
    console.log();
    console.log('Copying files...');
    console.log();
    fileMappings.forEach(mapping => {
        const destination = path.resolve(process.cwd(), mapping.destination);
        try {
            if (mapping.isDirectory) {
                copyDirectory(mapping.source, destination);
                console.log(chalk_1.default.green('✓'), `Copied directory: ${mapping.destination}/`);
            }
            else {
                copyFile(mapping.source, destination);
                console.log(chalk_1.default.green('✓'), `Copied file: ${mapping.destination}`);
            }
        }
        catch (error) {
            console.error(chalk_1.default.red('✗'), `Failed to copy ${mapping.destination}:`, error.message);
            throw error;
        }
    });
    console.log();
    console.log(chalk_1.default.green('✨ Guild setup complete!'));
    console.log();
    console.log('Your project now has:');
    console.log('  - .guild/         Guild documentation and workflows');
    console.log('  - CLAUDE.md       Instructions for AI assistants');
    console.log('  - .guild-config   Guild configuration file');
    console.log();
    console.log('Next steps:');
    console.log('  1. Review and customize .guild-config');
    console.log('  2. Read CLAUDE.md to understand the AI workflow');
    console.log('  3. Start using AI assistants with your Guild-enabled project!');
}
//# sourceMappingURL=copyDocs.js.map