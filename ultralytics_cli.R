uvx --python 3.12 --from ultralytics@8.3.69 yolo predict model=sam_b.pt source='/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/gbif_po/' imgsz=512

#https://huggingface.co/imageomics/butterfly_detection_yolo

uvx --python 3.12 --from ultralytics@8.3.69 --with dill yolo predict model=https://huggingface.co/imageomics/butterfly_detection_yolo/resolve/main/yolo_detection_8m_shear_10.0_scale_0.5_translate_0.1_fliplr_0.0_best.pt source='/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/testimages/' imgsz=512

python3 /Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/analysis/imageomics/wing-segmentation-main/preprocessing_scripts/resize_images_flat_dir.py --source /Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/testimages/ --output /Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/analysis/imageomics/out/resize --resize_dim 256 256

python3 wing-segmentation-main/preprocessing_scripts/resize_images_flat_dir.py --source '/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/testimages/' --output /out --resize_dim 256 256

#-----------------------------
#https://github.com/Imageomics/wing-segmentation
#segment
python3 wing-segmentation-main/segmentation_scripts/yolo_sam_predict_mask.py --dataset '/Users/lbuckley/yolotemp/images/testimages' --mask_csv ./out/segmentation_info.csv

#Remove background and all items that are not wings. Wings are placed against a white background
python3 wing-segmentation-main/segmentation_scripts/select_wings.py --images '/Users/lbuckley/yolotemp/images/testimages' --masks '/Users/lbuckley/yolotemp/images/testimages_masks' --main_folder testimages

#crop out the forewings and hindwings
python3 wing-segmentation-main/segmentation_scripts/crop_wings_out.py --images '/Users/lbuckley/yolotemp/images/testimages_wings_on_white_background' --masks '/Users/lbuckley/yolotemp/images/testimages_masks' --output_folder images/testimages_individual_wings --pad 1

#crop individual wings
python3 wing-segmentation-main/segmentation_scripts/select_individual_wings.py --images '/Users/lbuckley/yolotemp/images/testimages_wings_on_white_background' --masks '/Users/lbuckley/yolotemp/images/testimages_masks' --main_folder images
  
#read labels
#https://github.com/Imageomics/pybioclip

#landmarking tools
#https://github.com/Imageomics/Butterfly-mimicry

#Analysis in R
#imager
#opencv




