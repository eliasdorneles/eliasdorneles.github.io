package main

import (
	"io"
	"io/fs"
	"os"
	"path/filepath"
)

func copyFile(src, dst string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	return err
}

func copyDir(srcDir, dstDir string) error {
	return filepath.WalkDir(srcDir, func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}
		target := filepath.Join(dstDir, relPath)
		if entry.IsDir() {
			return os.MkdirAll(target, 0o755)
		}
		return copyFile(path, target)
	})
}

func copyAssets(outputDir string) error {
	if err := copyDir("site/images", filepath.Join(outputDir, "images")); err != nil {
		return err
	}
	if err := copyDir("mytheme/static", filepath.Join(outputDir, "theme")); err != nil {
		return err
	}
	return copyFile("site/extra/CNAME", filepath.Join(outputDir, "CNAME"))
}
