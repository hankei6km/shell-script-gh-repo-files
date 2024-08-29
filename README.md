# shell-script-gh-repo-files

GitHub 上のリポジトリから指定した Git 参照のファイルツリーを取得し他形式へ変換するツール。

主に NotebookLM のノートブック作成時にソースとしてリポジトリのファイルツリーを追加するために利用する。

> [!NOTE]
> Zenn で記事を作成するために作成したスクリプト。コードブロックに直接記述するのは手間なので、リポジトリのファイルを取得して記事に埋め込む形をとる。

## 使い方

### JSON へ変換

```
scripts/to-json/repo-files.sh <owner> <repo> <ref>
```

例:

```
scripts/to-json/repo-files.sh hankei6km shell-script-gh-repo-files main > "hankei6km shell-script-gh-repo-files main.txt"
```

> [!NOTE]
> NotebookLM では `.json` を直接追加できないので、拡張子は `.txt` にしている。

NotebookLM でノートブックを作成するときに、「テキスト ファイル」として追加するとソースとして利用できる。

なお、JSON 配列の各要素は 1 行で書き出しているので、`[]` と `,` を取り除けば ndjson としても扱えると思う(試してはないのでダメかもしれない)。

### HTML へ変換

```
scripts/to-html/repo-files.sh <owner> <repo> <ref>
```

例:

```
scripts/to-html/repo-files.sh hankei6km shell-script-gh-repo-files main > "hankei6km shell-script-gh-repo-files main.html"
```

> [!CAUTION]
> Google ドキュメントへ変換されることを想定して HTML を作成している。よって、簡単な HTML エスケープを行っているだけなので、作成された HTML を直接ブラウザーで開くのは危険。可能であれば rehype などでサニタイズするのが良い。

作成した HTML ファイルを Google ドライブへアップロードしファイルを右クリックして「アプリで開く / Google ドキュメント」を選択することで、Google ドキュメントファイルが作成される。

NotebookLM でノートブックを作成するときに、「ドライブ」からドキュメントを追加することでソースとして利用できる。

## ライセンス

MIT License

Copyright (c) 2024 hankei6km
