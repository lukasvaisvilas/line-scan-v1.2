fds = fileDatastore('Raw data/0/*.csv', 'ReadFcn', @importdata);
fullFileNames = fds.Files;
numFiles = length(fullFileNames);
Nx_values = zeros(numFiles, 1);
Ny_values = zeros(numFiles, 1);
Dv_values = zeros(numFiles, 1);
parFWHH_cell = cell(numFiles, 1);
perpFWHH_cell = cell(numFiles, 1);
perpintensity_cell = cell(numFiles, 1);
par_peak_count_cell = cell(numFiles, 1);

% Loop over each file
for k = 1 : numFiles

    %Reading data
    parx = readmatrix(fullFileNames{k}, 'range', 'A2:A231');  %NOTE: adjust range based on ROI length
    pary = readmatrix(fullFileNames{k}, 'range', 'B2:D231');  %NOTE: adjust range based on ROI length
    perpx = parx;
    perpy = readmatrix(fullFileNames{k}, 'range', 'D2:F231');  %NOTE: adjust range based on ROI length

    %Adjusting baseline for parallel line scans
    YA = msbackadj(parx, pary, 'PreserveHeights', true);

    %Calculating PFWHH parallel
    [parpeaks, PFWHH] = mspeaks(parx, YA, 'Multiplier', 1);  %NOTE: multiplier is adjustable

    
    % Remove peaks with a PFWHH greater than 15
    PFWHH_mask = (PFWHH{1,1}(:,2) - PFWHH{1,1}(:,1)) <= 15;
    parpeaks{1,1} = parpeaks{1,1}(PFWHH_mask,:);
    PFWHH_mask = (PFWHH{2,1}(:,2) - PFWHH{2,1}(:,1)) <= 15;
    parpeaks{2,1} = parpeaks{2,1}(PFWHH_mask,:);
    PFWHH_mask = (PFWHH{3,1}(:,2) - PFWHH{3,1}(:,1)) <= 15;
    parpeaks{3,1} = parpeaks{3,1}(PFWHH_mask,:);
    
    %Counting peaks for parallel line scans
    parnumpeaks1 = size(parpeaks{1,1},1);
    parnumpeaks2 = size(parpeaks{2,1},1);
    parnumpeaks3 = size(parpeaks{3,1},1);
   
    %Calculating mean peaks in parallel line scans (adjusted to /um)
    Nx = ((parnumpeaks1+parnumpeaks2+parnumpeaks3)/3)/100;
   
    %Storing PFWHH parallel
    parFWHH_cell{k} = [PFWHH{1,1};PFWHH{2,1};PFWHH{3,1}];

    %Adjusting baseline for perpendicular line scans
    YB = msbackadj(perpx, perpy, 'PreserveHeights', true);
   
    %Calculating PFWHH perpendicular
    [perppeaks, PFWHH] = mspeaks(perpx, YB, 'Multiplier', 1);  %NOTE: Multiplier is adjustable
    
    % Remove peaks with a PFWHH greater than 15
    PFWHH_mask = (PFWHH{1,1}(:,2) - PFWHH{1,1}(:,1)) <= 15;
    perppeaks{1,1} = perppeaks{1,1}(PFWHH_mask,:);
    PFWHH_mask = (PFWHH{2,1}(:,2) - PFWHH{2,1}(:,1)) <= 15;
    perppeaks{2,1} = perppeaks{2,1}(PFWHH_mask,:);
    PFWHH_mask = (PFWHH{3,1}(:,2) - PFWHH{3,1}(:,1)) <= 15;
    perppeaks{3,1} = perppeaks{3,1}(PFWHH_mask,:);
    
    %Counting peaks for perpendicular line scans
    perpnumpeaks1 = size(perppeaks{1,1},1);
    perpnumpeaks2 = size(perppeaks{2,1},1);
    perpnumpeaks3 = size(perppeaks{3,1},1);
   
    %Calculating mean peaks in parallel line scans (adjusted to /um)
    Ny = ((perpnumpeaks1+perpnumpeaks2+perpnumpeaks3)/3)/100;
   
    % Add the Nx value to the Nx_values array
    Nx_values(k) = Nx;
    Ny_values(k) = Ny;
    Dv_values(k) = ((Nx*Ny)/(100*cos(45)))*1000000;
end

%Remove outliers from Dv data
Dv_values_rmoutliers = rmoutliers(Dv_values);

%Calculate mean Dv (fibers/100um^3)
mean_Dv = mean(Dv_values_rmoutliers);

%plot(Dv_values, '.k');