#!/usr/bin/env node
"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const commander_1 = require("commander");
const chalk_1 = __importDefault(require("chalk"));
const copyDocs_1 = require("../lib/copyDocs");
const program = new commander_1.Command();
program
    .name('guild')
    .description('AI Guild CLI - Bootstrap your project with AI development workflows')
    .version('0.1.0');
program
    .command('setup')
    .description('Copy Guild documentation into your project')
    .option('--dry-run', 'Show what would be copied without actually copying')
    .action(async (options) => {
    try {
        await (0, copyDocs_1.setupCommand)(options);
    }
    catch (error) {
        console.error(chalk_1.default.red('Error:'), error.message);
        process.exit(1);
    }
});
program.parse(process.argv);
if (program.args.length === 0) {
    program.help();
}
//# sourceMappingURL=guild.js.map