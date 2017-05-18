% According to the face detection and alignment (facial landmarks
% detection) results. We investigate the error list incuding false
% detection, missing detection.
%
% revised by Dan
% May, 2017

clear;
%list of images [needs change]
imglist=importdata('H:\LR_POSE_FR_Data\Pointing04-pose-all\strangedetect.txt');
%minimum size of face
minsize=20;

%path of image
% imgroot = 'H:\LR_POSE_FR_Data\Pointing04-pose-all\';
imgroot = '';

%path of toolbox
caffe_path='F:\DeepLearning\caffe\matlab';
pdollar_toolbox_path='F:\DanTools\toolbox-master'
caffe_model_path='./model'
addpath(genpath(caffe_path));
addpath(genpath(pdollar_toolbox_path));

%use cpu
%caffe.set_mode_cpu();
gpu_id=0;
caffe.set_mode_gpu();	
caffe.set_device(gpu_id);

%three steps's threshold
threshold=[0.6 0.7 0.7]

%scale factor
factor=0.709;

%load caffe models
prototxt_dir =strcat(caffe_model_path,'/det1.prototxt');
model_dir = strcat(caffe_model_path,'/det1.caffemodel');
PNet=caffe.Net(prototxt_dir,model_dir,'test');
prototxt_dir = strcat(caffe_model_path,'/det2.prototxt');
model_dir = strcat(caffe_model_path,'/det2.caffemodel');
RNet=caffe.Net(prototxt_dir,model_dir,'test');	
prototxt_dir = strcat(caffe_model_path,'/det3.prototxt');
model_dir = strcat(caffe_model_path,'/det3.caffemodel');
ONet=caffe.Net(prototxt_dir,model_dir,'test');
faces=cell(0);	
for i=1:length(imglist)
    i
    strid = strfind(imglist{i},'.');
    imname = [imglist{i}(1:strid(1)) 'jpg']
    img=imread([imgroot imname]);
    tic
    [boudingboxes points]=detect_face(img,minsize,PNet,RNet,ONet,threshold,false,factor);
    faces{i,1}={boudingboxes};
	faces{i,2}={points'};
   %% CheckError-dan
   % missing detection - needs manually calibration
   % fault detection - 1. eliminate the redundant detected ROI. Normally,
   % the first face detection result is correct.
   % 2. otherwise the second is correct    
    if isempty(points)
        fprintf('missing detection num: %d\n', i)
        continue;
    elseif numel(points)>10 && i~=20 && i~=61
        Pts = reshape(points(:,1),5,2)'; 
    elseif numel(points)>10 && i==20 || i==61
        Pts = reshape(points(:,2),5,2)';
    end
    fid=fopen([imgroot imname(1:end-4) '.pts'],'wt');
    fprintf(fid, 'version: 1\n');
    fprintf(fid,'n_points: ');fprintf(fid,'%d\n',size(Pts,2));
    fprintf(fid,'{\n');
    for j=1:size(Pts,2)
        fprintf(fid,'%d %d\n',Pts(1,j),Pts(2,j));
    end
    fprintf(fid,'}');
    fprintf(fid,'\n');
    fclose(fid);   

%     if numel(points)==10
%         Pts = reshape(points,5,2)';
%         fid=fopen([imgroot imname(1:end-4) '.pts'],'wt');
%         fprintf(fid, 'version: 1\n');
%         fprintf(fid,'n_points: ');fprintf(fid,'%d\n',size(Pts,2));
%         fprintf(fid,'{\n');
%         for j=1:size(Pts,2)
%             fprintf(fid,'%d %d\n',Pts(1,j),Pts(2,j));
%         end
%         fprintf(fid,'}');
%         fprintf(fid,'\n');
%         fclose(fid);
%     end
    
 	%show detection result
	numbox=size(boudingboxes,1);
    imshow(img)
	hold on; 
	for j=1:numbox
		plot(points(1:5,j),points(6:10,j),'g.','MarkerSize',10);
		r=rectangle('Position',[boudingboxes(j,1:2) boudingboxes(j,3:4)-boudingboxes(j,1:2)],'Edgecolor','g','LineWidth',3);
    end
    hold off; 
%     pause;    
end

