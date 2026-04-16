name: Setup Flutter Project
on: push # جیسے ہی آپ یہ فائل سیو کریں گے، یہ کام شروع کر دے گا
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: |
          flutter create . --overwrite --org com.masail.hal
          git config --global user.email "action@github.com"
          git config --global user.name "GitHub Action"
          git add .
          git commit -m "Flutter project files created automatically"
          git push
