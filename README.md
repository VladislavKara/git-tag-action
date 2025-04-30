# Git Tag Action

Git Tag action is a github action that creates new tag or bump version of exited tags.

## Usage

```yaml
    runs-on: ubuntu-latest
    steps:
        - name: Checkout repository
          uses: actions/checkout@v4
        
        - name: Create tag
          uses: VladislavKara/git-tag-action@v1
          with:
            version: '1.0.0'
            verbose: true
            type: minor
```