import argparse
import random
import shutil
from pathlib import Path

import cv2


IMAGE_EXTS = {'.bmp', '.jpg', '.jpeg', '.png', '.tif', '.tiff'}


def parse_args():
    parser = argparse.ArgumentParser(description='Prepare HR/LR folders for remote-sensing SISR.')
    parser.add_argument('--source', required=True, help='Input folder containing HR images, recursively scanned.')
    parser.add_argument('--train-hr', default='KAIR-master/trainsets/remote/trainH')
    parser.add_argument('--test-hr', default='testsets/remote/HR')
    parser.add_argument('--test-lr', default='testsets/remote/LR_bicubic/X4')
    parser.add_argument('--scale', type=int, default=4)
    parser.add_argument('--test-ratio', type=float, default=0.1)
    parser.add_argument('--seed', type=int, default=42)
    parser.add_argument('--limit', type=int, default=0, help='Use only the first N shuffled images; 0 means all.')
    parser.add_argument('--min-size', type=int, default=32, help='Skip images smaller than this after mod-crop.')
    parser.add_argument('--clear-output', action='store_true')
    return parser.parse_args()


def clear_dir(path):
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def safe_name(path, source):
    rel = path.relative_to(source)
    stem = '_'.join(rel.with_suffix('').parts)
    return ''.join(ch if ch.isalnum() or ch in '._-' else '_' for ch in stem) + '.png'


def modcrop(img, scale):
    h, w = img.shape[:2]
    h = h - h % scale
    w = w - w % scale
    return img[:h, :w, :]


def write_pair(src_path, source, hr_dir, lr_dir, scale, min_size):
    img = cv2.imread(str(src_path), cv2.IMREAD_COLOR)
    if img is None:
        return False

    img = modcrop(img, scale)
    h, w = img.shape[:2]
    if h < min_size or w < min_size:
        return False

    out_name = safe_name(src_path, source)
    hr_path = hr_dir / out_name
    lr_path = lr_dir / out_name
    lr = cv2.resize(img, (w // scale, h // scale), interpolation=cv2.INTER_CUBIC)
    cv2.imwrite(str(hr_path), img)
    cv2.imwrite(str(lr_path), lr)
    return True


def write_hr(src_path, source, out_dir, scale, min_size):
    img = cv2.imread(str(src_path), cv2.IMREAD_COLOR)
    if img is None:
        return False

    img = modcrop(img, scale)
    h, w = img.shape[:2]
    if h < min_size or w < min_size:
        return False

    out_path = out_dir / safe_name(src_path, source)
    cv2.imwrite(str(out_path), img)
    return True


def main():
    args = parse_args()
    source = Path(args.source).expanduser().resolve()
    train_hr = Path(args.train_hr)
    test_hr = Path(args.test_hr)
    test_lr = Path(args.test_lr)

    if not source.exists():
        raise FileNotFoundError(f'Source folder does not exist: {source}')

    if args.clear_output:
        clear_dir(train_hr)
        clear_dir(test_hr)
        clear_dir(test_lr)
    else:
        train_hr.mkdir(parents=True, exist_ok=True)
        test_hr.mkdir(parents=True, exist_ok=True)
        test_lr.mkdir(parents=True, exist_ok=True)

    image_paths = [p for p in source.rglob('*') if p.suffix.lower() in IMAGE_EXTS]
    if not image_paths:
        raise RuntimeError(f'No images found under {source}')

    rng = random.Random(args.seed)
    rng.shuffle(image_paths)
    if args.limit > 0:
        image_paths = image_paths[:args.limit]

    test_count = max(1, int(len(image_paths) * args.test_ratio))
    test_set = set(image_paths[:test_count])
    train_set = image_paths[test_count:]

    train_written = sum(write_hr(p, source, train_hr, args.scale, args.min_size) for p in train_set)
    test_written = sum(write_pair(p, source, test_hr, test_lr, args.scale, args.min_size) for p in test_set)

    print(f'Source images: {len(image_paths)}')
    print(f'Train HR written: {train_written} -> {train_hr}')
    print(f'Test HR written: {test_written} -> {test_hr}')
    print(f'Test LR written: {test_written} -> {test_lr}')


if __name__ == '__main__':
    main()
