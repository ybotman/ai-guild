import * as fs from 'fs';
import * as path from 'path';
import chalk from 'chalk';
import inquirer from 'inquirer';

interface FileMapping {
  source: string;
  destination: string;
  isDirectory: boolean;
}

interface FileToCopy {
  source: string;
  destination: string;
  exists: boolean;
}

interface SetupOptions {
  dryRun?: boolean;
}

// Get the package root directory (parent of parent of lib/)
const packageRoot = path.resolve(__dirname, '../..');

// Define source and destination mappings
const fileMappings: FileMapping[] = [
  {
    source: path.join(packageRoot, 'guild-docs/.guild'),
    destination: '.guild',
    isDirectory: true,
  },
  {
    source: path.join(packageRoot, 'guild-docs/Setup/NewCLAUDE.md'),
    destination: 'CLAUDE.md',
    isDirectory: false,
  },
  {
    source: path.join(packageRoot, 'guild-docs/Setup/.guild-config.example'),
    destination: '.guild-config',
    isDirectory: false,
  },
];

// Check if a file or directory exists
function exists(filePath: string): boolean {
  try {
    fs.accessSync(filePath);
    return true;
  } catch {
    return false;
  }
}

// Copy a file
function copyFile(source: string, destination: string): void {
  fs.copyFileSync(source, destination);
}

// Copy a directory recursively
function copyDirectory(source: string, destination: string): void {
  // Create destination directory if it doesn't exist
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
    } else {
      copyFile(sourcePath, destPath);
    }
  });
}

// Get all files that would be copied (for dry-run and confirmation)
function getFilesToCopy(): FileToCopy[] {
  const files: FileToCopy[] = [];

  fileMappings.forEach(mapping => {
    const destination = path.resolve(process.cwd(), mapping.destination);

    if (mapping.isDirectory) {
      // For directories, get all files recursively
      const getAllFiles = (dir: string, baseDir: string): void => {
        const dirFiles = fs.readdirSync(dir);
        dirFiles.forEach(file => {
          const fullPath = path.join(dir, file);
          const stats = fs.statSync(fullPath);
          const relativePath = path.relative(baseDir, fullPath);
          const destPath = path.join(destination, relativePath);

          if (stats.isDirectory()) {
            getAllFiles(fullPath, baseDir);
          } else {
            files.push({
              source: fullPath,
              destination: destPath,
              exists: exists(destPath),
            });
          }
        });
      };

      if (exists(mapping.source)) {
        getAllFiles(mapping.source, mapping.source);
      }
    } else {
      files.push({
        source: mapping.source,
        destination: destination,
        exists: exists(destination),
      });
    }
  });

  return files;
}

// Main setup command
export async function setupCommand(options: SetupOptions): Promise<void> {
  console.log(chalk.blue('🏰 Guild Setup'));
  console.log();

  // Get all files that would be copied
  const filesToCopy = getFilesToCopy();
  const existingFiles = filesToCopy.filter(f => f.exists);

  // Dry run mode
  if (options.dryRun) {
    console.log(chalk.yellow('DRY RUN MODE - No files will be copied'));
    console.log();
    console.log('The following operations would be performed:');
    console.log();

    filesToCopy.forEach(file => {
      const status = file.exists ? chalk.yellow('[OVERWRITE]') : chalk.green('[CREATE]');
      console.log(`${status} ${file.destination}`);
    });

    return;
  }

  // Check for existing files and prompt for confirmation
  if (existingFiles.length > 0) {
    console.log(chalk.yellow('⚠️  The following files already exist and will be overwritten:'));
    console.log();
    existingFiles.forEach(file => {
      console.log(`  - ${file.destination}`);
    });
    console.log();

    const { confirm } = await inquirer.prompt<{ confirm: boolean }>([
      {
        type: 'confirm',
        name: 'confirm',
        message: 'Do you want to proceed with overwriting these files?',
        default: false,
      },
    ]);

    if (!confirm) {
      console.log(chalk.red('Setup cancelled.'));
      process.exit(0);
    }
  }

  // Perform the actual copying
  console.log();
  console.log('Copying files...');
  console.log();

  fileMappings.forEach(mapping => {
    const destination = path.resolve(process.cwd(), mapping.destination);

    try {
      if (mapping.isDirectory) {
        copyDirectory(mapping.source, destination);
        console.log(chalk.green('✓'), `Copied directory: ${mapping.destination}/`);
      } else {
        copyFile(mapping.source, destination);
        console.log(chalk.green('✓'), `Copied file: ${mapping.destination}`);
      }
    } catch (error: any) {
      console.error(chalk.red('✗'), `Failed to copy ${mapping.destination}:`, error.message);
      throw error;
    }
  });

  console.log();
  console.log(chalk.green('✨ Guild setup complete!'));
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
