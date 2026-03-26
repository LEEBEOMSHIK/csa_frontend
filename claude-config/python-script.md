# 기본 실행
python split_assets.py --input assets/images/before/남자아이.png

# 분류 오류 수정
python split_assets.py --input 남자아이.png --override category_override.json

# 얼굴 앵커 고정
python split_assets.py --input 남자아이.png --anchor-override anchor_override.json

# 폴더 전체 처리 (에러 있어도 계속)
python split_assets.py --input assets/images/before/