clc
clear all
close all

orig=imread('indoor.jpg');
figure, imshow(orig),title('Original');
originfo = imfinfo('indoor.jpg');

% convert to gray
i = orig;
R = i(:, :, 1);
G = i(:, :, 2);
B = i(:, :, 3);
imagegray = zeros(size(i,1), size(i,2), 'uint8');

for x=1:size(i,1)
   for y=1:size(i,2)
       imagegray(x,y) = (R(x,y)*.3)+(G(x,y)*.6)+(B(x,y)*.1);
   end
end
figure, imshow(imagegray),title('gray');
imwrite(imagegray,'indoor_1024gray.jpg');

        
% convert to 1024 * 1024
imageresize = imresize(imagegray,[1024 1024]);
figure, imshow(imageresize),title('1024');
imwrite(imageresize,'indoor_1024convert.jpg');




 % DCT
 fun = @(block_struct) dct2(block_struct.data);
 imageDCT   = blockproc(imageresize,[8 8],fun);
 DF2 = imageDCT/16;
 
figure, imshow(DF2),title('dct2');
 imwrite(DF2,'indoor_1024DF.jpg');

 %Quantize process
 % JPEG default quantization array
    Q_8x8 =uint8([
            16 11 10 16  24  40  51  61
            12 12 14 19  26  58  60  55
            14 13 16 24  40  57  69  56
            14 17 22 29  51  87  80  62
            18 22 37 56  68 109 103  77
            24 35 55 64  81 104 113  92
            49 64 78 87 103 121 120 101
            72 92 95 98 112 100 103 99]);
        
dct_transformed_image = imageDCT/16;
Maximum_Value_of_dct_coeffieient = max(max(dct_transformed_image));

 dct_transformed_image_coeffieient = dct_transformed_image./Maximum_Value_of_dct_coeffieient;
    
    %integer conversion of dct_transformed_image 
    dct_transformed_image_int = im2uint8( dct_transformed_image_coeffieient ); 
    
    quantization_matrix = repmat(Q_8x8,1024/8,1024/8 ); %for coarse quantization
    quantized_image =  round(dct_transformed_image_int ./quantization_matrix) ; %round operation should be done
    
    ZigZag_Order = uint8([
            1  9  2  3  10 17 25 18
            11 4  5  12 19 26 33 41
            34 27 20 13 6  7  14 21 
            28 35 42 49 57 50 43 36 
            29 22 15 8  16 23 30 37
            44 51 58 59 52 45 38 31 
            24 32 39 46 53 60 61 54 
            47 40 48 55 62 63 56 64]);
        % Break 8x8 block into columns
        %ZigZag_Order_matrix = repmat(ZigZag_Order,1024/8,1024/8 );
        %ZigZaged_Single_Column_Image=quantized_image(ZigZag_Order_matrix,:);  
        
          % Finding the reverse zigzag order (8x8 matrix)
    reverse_zigzag_order_8x8 = zeros(8,8);
    for k = 1:(size(ZigZag_Order,1) *size(ZigZag_Order,2)) 
        reverse_zigzag_order(k) = find(ZigZag_Order== k); 
    end;
    
        
    Single_column_quantized_image=im2col(quantized_image, [8 8],'distinct');
     %--------------------------- zigzag ----------------------------------
    % using the MatLab Matrix indexing power (specially the ':' operator) rather than any function
    ZigZaged_Single_Column_Image=Single_column_quantized_image(ZigZag_Order,:);    
    %---------------------------------------------------------------------
     %---------------------- Run Level Coding -----------------------------
    % construct Run Level Pair from ZigZaged_Single_Column_Image
    run_level_pairs=uint8([]);
    for block_index=1:1024*1024/64    %block by block - total 1024*1024/256 blocks (8x8) in the 1024x1024 image
        single_block_image_vector_64(1:64)=0;
        for Temp_Vector_Index=1:64
            single_block_image_vector_64(Temp_Vector_Index) = ZigZaged_Single_Column_Image(Temp_Vector_Index, block_index);  %select 1 block sequentially from the ZigZaged_Single_Column_Image
        end
        non_zero_value_index_array = find(single_block_image_vector_64~=0); % index array of next non-zero entry in a block
        number_of_non_zero_entries = length(non_zero_value_index_array);  % # of non-zero entries in a block
         % Case 1: if first ac coefficient has no leading zeros then encode first coefficient
        if non_zero_value_index_array(1)==1,  
           run=0;   % no leading zero
            run_level_pairs=cat(1,run_level_pairs, run, single_block_image_vector_64(non_zero_value_index_array(1)));
        end

    % Case 2: loop through each non-zero entry    
        for n=2:number_of_non_zero_entries, 
            % check # of leading zeros (run)
            run=non_zero_value_index_array(n)-non_zero_value_index_array(n-1)-1;
            run_level_pairs=cat(1, run_level_pairs, run, single_block_image_vector_64(non_zero_value_index_array(n)));
        end
        
    % Case 3: "End of Block" mark insertion
        run_level_pairs=cat(1, run_level_pairs, 255, 255);
    end
    %---------------------------------------------------------------------
    imageresizeinfo = imfinfo('indoor_1024convert.jpg');
     Compressed_image_size=size(run_level_pairs);        % file size after compression
    Compression_Ratio = imageresizeinfo.FileSize/Compressed_image_size(1,1);
    
    fid = fopen('indoor_Compression_Ratio.txt','wt');
    fprintf(fid,'%g\r\n',Compressed_image_size(1,1));
    fprintf(fid,'%g\r\n',Compression_Ratio);
    fclose(fid);
    %-----add 50 to quantilization table
    Q_8x8_50 = Q_8x8 +50;
    
    quantization_matrix_50 = repmat(Q_8x8_50,1024/8,1024/8 ); %for coarse quantization
    quantized_image_50 =  round(dct_transformed_image_int ./quantization_matrix_50) ; %round operation should be done
    
     Single_column_quantized_image_50=im2col(quantized_image_50, [8 8],'distinct');
     %--------------------------- zigzag ----------------------------------
    ZigZaged_Single_Column_Image_50=Single_column_quantized_image_50(ZigZag_Order,:);    
     %---------------------- Run Level Coding -----------------------------
    run_level_pairs_50=uint8([]);
    for block_index=1:1024*1024/64    %block by block - total 1024*1024/256 blocks (8x8) in the 1024x1024 image
        single_block_image_vector_64_50(1:64)=0;
        for Temp_Vector_Index=1:64
            single_block_image_vector_64_50(Temp_Vector_Index) = ZigZaged_Single_Column_Image_50(Temp_Vector_Index, block_index);  %select 1 block sequentially from the ZigZaged_Single_Column_Image
        end
        non_zero_value_index_array_50 = find(single_block_image_vector_64~=0); % index array of next non-zero entry in a block
        number_of_non_zero_entries_50 = length(non_zero_value_index_array_50);  % # of non-zero entries in a block
         % Case 1: if first ac coefficient has no leading zeros then encode first coefficient
        if non_zero_value_index_array_50(1)==1,  
           run=0;   % no leading zero
            run_level_pairs_50=cat(1,run_level_pairs_50, run, single_block_image_vector_64_50(non_zero_value_index_array_50(1)));
        end

    % Case 2: loop through each non-zero entry    
        for n=2:number_of_non_zero_entries_50, 
            % check # of leading zeros (run)
            run=non_zero_value_index_array_50(n)-non_zero_value_index_array_50(n-1)-1;
            run_level_pairs_50=cat(1, run_level_pairs_50, run, single_block_image_vector_64_50(non_zero_value_index_array_50(n)));
        end
        
    % Case 3: "End of Block" mark insertion
        run_level_pairs_50=cat(1, run_level_pairs_50, 255, 255);
    end
    %---------------------------------------------------------------------
    
    % % %  -------------------------------------------------------------------
% % %  -------------------------------------------------------------------
% % %                DECODING
% % %  -------------------------------------------------------------------
% % %  -------------------------------------------------------------------

%---------------------- Run Level Decoding ---------------------------
    % construct  ZigZaged_Single_Column_Image from Run Level Pair 
    c=[];
    for n=1:2:size(run_level_pairs_50), % loop through run_level_pairs
        % Case 1 & Cae 2 
        % concatenate zeros according to 'run' value
        if run_level_pairs_50(n)<255 % only end of block should have 255 value
            zero_count=0;
            zero_count=run_level_pairs_50(n);
            for l=1:zero_count    % concatenation of zeros accouring to zero_count
                c=cat(1,c,0);   % single zero concatenation
            end
            c=cat(1,c,run_level_pairs_50(n+1)); % concatenate single'level' i.e., a non zero value
       
        % Case 3: End of Block decoding
        else
            number_of_trailing_zeros= 64-mod(size(c),64);
            for l= 1:number_of_trailing_zeros    % concatenate as much zeros as needed to fill a block
                c=cat(1,c,0); 
            end
        end
    end
    %---------------------------------------------------------------------
    

    %---------------------------------------------------------------------
    %    prepare the ZigZaged_Single_Column_Image vector (each column represents 1 block) from the
    %    intermediate concatenated vector "c"
    for i=1:1024*1024/64
        for j=1:64
            ZigZaged_Single_Column_Image_reverse(j,i)=c(64*(i-1)+j);
        end
    end
    %---------------------------------------------------------------------
     
    
    %--------------------------- reverse zigzag --------------------------
    %reverse zigzag procedure using the matrix indexing capability of MatLab (specially the ':' operator)
    Single_column_quantized_image_reverse = ZigZaged_Single_Column_Image_reverse(reverse_zigzag_order,:);
    %---------------------------------------------------------------------
    
    %image matrix construction from image column
    quantized_image_reverse = col2im(Single_column_quantized_image_reverse,   [8 8],   [1024 1024],   'distinct');

    
    %-------------------- deQuantization ---------------------------------
    dct_transformed_image_reverse =  quantized_image_reverse.*quantization_matrix_50 ;
    %dct_transformed_image_reverse =  quantized_image_50.*quantization_matrix_50 ;
    %---------------------------------------------------------------------
    dct_transformed_image_coeffieient_double= im2double(dct_transformed_image_reverse);
    dct_transformed_image_inverse_double= dct_transformed_image_coeffieient_double * Maximum_Value_of_dct_coeffieient;
    dct_transformed_image_inverse = dct_transformed_image_inverse_double *16;
    %dct_transformed_image_inverse=im2uint8(dct_transformed_image_reverse).*Maximum_Value_of_dct_coeffieient *16

    figure, imshow(dct_transformed_image_inverse_double),title('Reversedct2');
    imwrite(dct_transformed_image_inverse_double,'indoor_1024ReverseDF.jpg');
 
     %-------------------------- Inverse DCT ------------------------------
    % restore the compressed image from the given set of coeficients
     funidct = @(block_struct) idct2(block_struct.data);
     restored_image    = blockproc(dct_transformed_image_inverse,[8 8],funidct);
     %restored_image    = blockproc(imageDCT,[8 8],funidct);
     restored_image_int = uint8(restored_image)
     figure, imshow(restored_image_int),title('Reverse');
     imwrite(restored_image_int,'indoor_1024reverse.jpg');
     
%H = [1 2 1; 0 0 0; -1 -2 -1];
H=[0.0025,0.0125,0.02,0.0125,0.0025;
    0.0125,0.0625,0.1,0.0625,0.0125;
    0.02,0.1,0.16,0.1,0.02;
    0.0125,0.0625,0.1,0.0625,0.0125;
    0.0025,0.0125,0.02,0.0125,0.0025];

% convert to 300 * 300
imageresize_300 = imresize(imagegray,[300 300]);
figure, imshow(imageresize_300),title('300');
imwrite(imageresize_300,'indoor_300convert.jpg');

%5x5
Quafilter_5x5 = filter2(H,imageresize_300)/255;
imwrite(Quafilter_5x5,'indoor_Quafilter_5x5.jpg');
figure, imshow(Quafilter_5x5),title('Quafilter_5x5');

%3x3
Quafilter_3x3 = filter2(fspecial('average',3),imageresize_300)/255;
imwrite(Quafilter_3x3,'indoor_Quafilter_3x3.jpg');
figure, imshow(Quafilter_3x3),title('Quafilter_3x3');

%9x9
Quafilter_9x9 = filter2(fspecial('average',9),imageresize_300)/255;
imwrite(Quafilter_9x9,'indoor_Quafilter_9x9.jpg');
figure, imshow(Quafilter_9x9),title('Quafilter_9x9');


