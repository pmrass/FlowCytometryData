function [pooledCollectedResults] = ReadCSVFlowDataFromFile(RearrangeStructure)
%READCSVFLOWDATAFROMFILE Summary of this function goes here
%   Detailed explanation goes here
        
        fileNameBase =                              RearrangeStructure.fileNameBase;
        fileName =                                  RearrangeStructure.fileName;
        
        listWithFileNames  =                        cellfun(@(x) [fileNameBase, x], fileName, 'UniformOutput', false);
        text =                                      cellfun(@(x) fileread(x), listWithFileNames, 'UniformOutput', false);
        C =                                         cellfun(@(x) (strsplit(x,'\n'))', text, 'UniformOutput', false);

        NumberOfFiles =                             size(C,1);
        
        for fileIndex = 1:NumberOfFiles


            C{fileIndex} =                           cellfun(@(x) removeCommasInFileName(x), C{fileIndex},'UniformOutput', false);

            currentResult=                          cellfun(@(x) strsplit(x,','), C{fileIndex},'UniformOutput', false);

            conciseResult =                         currentResult(2:end-3,:);
            
            if fileIndex == 1 && strcmp('/20170919_ChemokineReceptor.csv', fileName{fileIndex}) % cxcr3 data and cxcr4 data are from different gates and need to manipulated;
                
                % really annoying that I have to do this: make sure this is correct;
                
                numberOfRows =                                      size(conciseResult,1);
                BottomHalf =                                        conciseResult(numberOfRows/2+1:numberOfRows,:);
                conciseResult(numberOfRows/2+1:numberOfRows,:)=     [];
                conciseResult =                                     [conciseResult, BottomHalf];
                
                tempResult =                                        cellfun(@(x,y) horzcat([x(1:8),y(4:7),x(9:12),y(8:end)]), conciseResult(:,1), conciseResult(:,2),'UniformOutput', false);
                
                conciseResult =                                     tempResult;
            end
            
            niceResult =                                            vertcat(conciseResult{:});
            collectedResults{fileIndex,1} =                         niceResult;

        end

        pooledCollectedResults =                    vertcat(collectedResults{:});

end


function [string] = removeCommasInFileName(string)


    apostrophe = find(string == '"');
    if length(apostrophe)==2

        substring = string(apostrophe(1):apostrophe(2));
        substring(substring==',') = '_';
        string(apostrophe(1):apostrophe(2)) = [substring(2:end-1), '  '];

    end


end
