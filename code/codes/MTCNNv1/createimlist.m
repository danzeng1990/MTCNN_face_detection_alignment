rootpath = 'H:\LR_POSE_FR_Data\Pointing04-pose-all\';
allims = dir([rootpath '*.jpg']);

num = length(allims);

file = fopen([rootpath 'imlist.txt'], 'wt');
for i = 1:num
    fprintf(file, '%s\n', [rootpath allims(i).name]);
end
fclose(file);