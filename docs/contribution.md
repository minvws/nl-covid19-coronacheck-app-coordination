# How to handle contributions

We usually welcome contributions from external people as long as they add value to the relevant repository.
You can follow this flow to process a contribution:
1. Review the code of the pull request and provide feedback to the author if needed
2. Check the commit messages that they reflect the changes being made (checking git blame long time afterwards should be clear why this change was made)
3. Open a pull request to the main branch of the private repo
    - Check if there are any conflicts (they may have worked internally on the same files since last release).
    - Check and approve the code changes when the CI is green (lint, tests pass etc)
    - A build will be made for QA to test what's changed and make sure there are no regressions.
    - After QA approves, the changes will be merged to the private repo.
    - The changes will be included in the next release and will be merged back to the public repo when the release is out.