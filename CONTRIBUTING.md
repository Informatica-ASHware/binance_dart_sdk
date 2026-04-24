# Contributing to binance_dart_sdk

First off, thank you for considering contributing to this SDK! It's people like you that make it a great tool for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

- Check if the bug has already been reported in the Issues.
- If not, open a new issue. Include a clear title, a description of the bug, and steps to reproduce it.

### Suggesting Enhancements

- Open a new issue with the tag "enhancement".
- Describe the feature you'd like to see and why it would be useful.

### Pull Requests

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`melos run test`).
5. Make sure your code lints (`melos run analyze`).
6. Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

## Style Guide

- Follow the official [Dart Style Guide](https://dart.dev/guides/language/analysis-options).
- We use `very_good_analysis` for linting.
- All public APIs must have Dartdoc comments.

## Development Workflow

1. `melos bootstrap` to set up the workspace.
2. `melos run analyze` to check for linting issues.
3. `melos run test` to run tests.
4. `melos run format` to format your code.

Thank you for your contributions!
