% According to the demo to batchly extracted landmarks of the wanted
% database.
% All faces need to set in the same folder, subfolders are not allowed.
%
% revised by Dan
% May, 2017

clear;
%list of images [needs change]
imglist=importdata('H:\LR_POSE_FR_Data\Pointing04-pose-all\imlist.txt');
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
fid2=fopen('H:\LR_POSE_FR_Data\Pointing04-pose-all\errordetect.txt','wt');
for i=1:length(imglist)
    i
    imname = imglist{i};
    img=imread([imgroot imname]);
    tic
    [boudingboxes points]=detect_face(img,minsize,PNet,RNet,ONet,threshold,false,factor);
    faces{i,1}={boudingboxes};
	faces{i,2}={points'};
    
   %% ADD-dan
    % we assume that only one face appears in one image. Points including
    % left eye center, right eye center, nose tip, left mouth corner and
    % right mouth corner are stored in sorts. X of coords first, then Y.
    % Here we store the error detect list when there are not one face
    % detected in the image.
    if numel(points)==10
        Pts = reshape(points,5,2)';
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
    else
        fprintf(fid2,'%s\t%d\n',imname,i);
        continue
    end
    
 	%show detection result
% 	numbox=size(boudingboxes,1);
%     imshow(img)
% 	hold on; 
% 	for j=1:numbox
% 		plot(points(1:5,j),points(6:10,j),'g.','MarkerSize',10);
% 		r=rectangle('Position',[boudingboxes(j,1:2) boudingboxes(j,3:4)-boudingboxes(j,1:2)],'Edgecolor','g','LineWidth',3);
%     end
%     hold off; 
%     pause;    
end




