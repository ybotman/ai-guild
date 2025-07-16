#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import { setupCommand } from '../lib/copyDocs';

const program = new Command();

program
  .name('guild')
  .description('AI Guild CLI - Bootstrap your project with AI development workflows')
  .version('0.1.0');

program
  .command('setup')
  .description('Copy Guild documentation into your project')
  .option('--dry-run', 'Show what would be copied without actually copying')
  .action(async options => {
    try {
      await setupCommand(options);
    } catch (error: any) {
      console.error(chalk.red('Error:'), error.message);
      process.exit(1);
    }
  });

program.parse(process.argv);

// Show help if no command is provided
if (program.args.length === 0) {
  program.help();
}
