classdef PMFlowJoFileIDCodes
    %PMFLOWJOFILEIDCODES parses content of text file containing information about data sources for different groups;
    % format of source file:
    % list contains different keys: keys are highlighted by * at the beginning of the line;
    % each key is followed by names of the files that contain the actual numerical information (exported from FloJo);
    % different files in the same group are separated by a comma; different groups are separated by a semicolon;
    
    properties (Access = private)
        FolderName
        FileName = 'FlowJoFileIDCodes.txt'
        ActiveKey
        FolderWithSourceData
        
    end
    
    properties (Access = private) % read from file
        
        ListWithAllKeys
        ListWithFileTextsForAllKeys
        
        FileTextsForActiveKey
        
        
        
    end
    
    methods % INITILIZATION
        
        
        function obj = PMFlowJoFileIDCodes(varargin)
            %PMFLOWJOFILEIDCODES Construct an instance of this class
            % takes 4 arguments:
            % 1: character of name of folder with 'FlowJoFileIDCodes.txt' file
            % 2: character with name of active key; the object will then retrieve the file-codes that are linked to the ;
            % 3: filename of folder with file-ID codes;
            % 4: folder with source-data (used to verify that the file-names defined in the ID-codes file actually exist;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
            
                case 4
                    obj.FolderName =            varargin{1};
                    obj.FileName  =             varargin{3};
                    obj.ActiveKey =             varargin{2};
                    obj.FolderWithSourceData =  varargin{4};
                    obj =                       obj.setPropertiesFromFile;
                    obj =                       obj.verifyFileConnection;
                        
                otherwise
                    error('Wrong input.')
                
            end
            
             
           
          
            
        end
        
        function obj = set.FolderName(obj, Value)
            assert(ischar(Value), 'Wrong input.')
            obj.FolderName = Value;
        end
        
        function obj = set.FileName(obj, Value)
            assert(ischar(Value), 'Wrong input.')
            obj.FileName = Value;
        end
        
        function obj = set.ActiveKey(obj, Value)
             assert(ischar(Value), 'Wrong input.')
             obj.ActiveKey = Value;
             
        end
        
        function obj = set.FolderWithSourceData(obj, Value)
           assert(ischar(Value), 'Wrong input.')
           obj.FolderWithSourceData = Value;
            
        end
        
        
    end
    
    methods % summary
       
          function obj = showSummary(obj, varargin)
              
              switch length(varargin)
                 
                  case 0
                      
                      cellfun(@(x) fprintf('%s\n', x), obj.getSummary);
                      
                      
                      
                  case 1
                      
                      switch varargin{1}
                         
                          case 'ActiveKey'
                              cellfun(@(x) fprintf('%s\n', x), obj.getFileCodeTextForActiveKey);
                              
                          otherwise
                              error('Wrong input.')
                          
                          
                      end
                        
                        
                    
                      
                      
                  otherwise
                      error('Wrong input.')
                  
                  
              end
          
          end
        
          function Text = getSummary(obj, varargin)
              
              
                   switch length(varargin)
                 
                  case 0
                      
                          Text{1} =  sprintf('\n*** This PMFlowJoFileIDCodes object has the main function to retrieve filenames saved in a text file.');
             Text = [Text; sprintf('This text file contains several "keys" that represent a certain combination of files.\n')];
             Text = [Text; sprintf('Each key is followed by a list of filenames that are linked to a particular key.\n')];
             Text = [Text; sprintf('\nThis object''s  source file is in folder %s and has the name %s.\n', obj.FolderName, obj.FileName)];
             Text = [Text; sprintf('\nThis file has filenames linked to the following keys:')];
             Text = [Text; cellfun(@(x) sprintf('%s\n', x), obj.ListWithAllKeys, 'UniformOutput', false);];
             Text = [Text; sprintf('\nThe selected active key is: "%s" and contains the following file-names:\n', obj.ActiveKey)];
            
    
             Text = [Text; obj.getFileCodeTextForActiveKey];
                      
                      
                      
                  case 1
                      
                      switch varargin{1}
                         
                          case 'ActiveKey'
                              Text = obj.getFileCodeTextForActiveKey;
                              
                          otherwise
                              error('Wrong input.')
                          
                          
                      end
                        
                        
                    
                      
                      
                  otherwise
                      error('Wrong input.')
                  
                  
                   end
          
              
                   
         
             
         
              
          end
        
    end
    
    methods % getters

          function FileCodes = getFileCodes(obj)
            error('Use getFileCodesPerGroup.')
          
          end
          
          function fileCodesPerGroup = getFileCodesPerGroup(obj)
                %GETFILECODES get filenames linked to active key, split by groups;
                % output is a cell array: each cell contains a cell-string with the names of the file-names linked to each group;
                fileCodesPerGroup =                  obj.FileTextsForActiveKey;
            
              
          end
        
          
        function key = getActiveKey(obj)
            key = obj.ActiveKey;

        end

        function panelTitles = getPanelTitles(obj)
            %GETPANELTITLES get title for each panel based on file codes;
            % the title is drawn from the string and keeps only the string before the second under-line so that the string should contain date and day of the experiment;
            strings =          cellfun(@(x) PMString(x), obj.FileTextsForActiveKey);
            panelTitles =      arrayfun(@(x) x.getTruncatedStringsBefore('_', 2), strings, 'UniformOutput', false);

        end
        
        function number = getNumberOfGroups(obj)
           number = length(obj.FileTextsForActiveKey);
        end
        
        function folder = getDataSourceFolder(obj)
            folder  = obj.FolderWithSourceData;
            
        end


    end
    


    
    
 
    
   
      
    methods (Access = private) % keys
        
        
        function  obj = setPropertiesFromFile(obj)
            text =      fileread([obj.FolderName '/' obj.FileName]);
            Blocks =    (strsplit(text, '*'))';
            
            obj.ListWithAllKeys =               cellfun(@(x) obj.getTitle(x), Blocks, 'UniformOutput', false);
            obj.ListWithFileTextsForAllKeys =       cellfun(@(x) obj.getFileNames(x), Blocks, 'UniformOutput', false);
            
              
                FileNameTextForActiveKey =          obj.ListWithFileTextsForAllKeys{obj.getFilterIndexForActiveKey};
                namesSplitBetweenGroups =           obj.splitTextBetweenGroups(FileNameTextForActiveKey);

                fileCodesPerGroup =                   cellfun(@(x) obj.splitFileNamesWithinGroups(x), namesSplitBetweenGroups, 'UniformOutput', false);
            
                
            obj.FileTextsForActiveKey =     fileCodesPerGroup;
        
        end
        
        function title = getTitle(~, Text)
            title = strsplit(Text, ':');
            title = title{1};
            title = strtrim(title);
            
        end

        function title = getFileNames(~, Text)
            title = strsplit(Text, ':');
            if length(title)<2
                title = '';
            else
                title = title{2};
            end
        end
        
         
         
     
    
        
      
        
        
    end
    
      methods (Access = private) % GETTERS: PARSE FILE-TEXTS FOR ACTIVE KEY;
         
     
        
          function RowFilter = getFilterIndexForActiveKey(obj)
              RowFilter = obj.getFilterIndexForKey(obj.ActiveKey);
              
              
            
          end
          
          function RowFilter = getFilterIndexForKey(obj, Key)
              
                RowFilter =     strcmp(obj.ListWithAllKeys, Key);
                
                if sum(RowFilter) ~= 1
                    fprintf('The chosen key "%s" has no unique match in the following list.\n', Key)
                    cellfun(@(x) fprintf('%s.\n', x), obj.ListWithAllKeys)
                    error('The key "%s" has no unique match.', Key)
                end
                
              
          end
          
          
          
        function MySplitFileNames = splitTextBetweenGroups(~, MyFileNames)

            MySplitFileNames =         (strsplit(MyFileNames, ';'))';
            MySplitFileNames  =        cellfun(@(x) strtrim(x), MySplitFileNames, 'UniformOutput', false);
            empty =                    cellfun(@(x) isempty(x), MySplitFileNames);
            MySplitFileNames(empty) =  [];

        end
        
        
         function finalizedNames = splitFileNamesWithinGroups(obj, FileName)
             splitNames =           (strsplit(FileName, ','))';
             empty =                cellfun(@(x) isempty(x), splitNames);
             splitNames(empty) =    [];
             
             finalizedNames = cellfun(@(x) obj.finalizeFileName(x), splitNames, 'UniformOutput', false);
             
         end
         
         function Name = finalizeFileName(~, Name)
             Name = strtrim(Name);
             Name(Name== '''') = [];
         end
        
      
        
         
      end
      
      methods (Access = private) % GETTERS SUMMARY
          
          function Text = getFileCodeTextForActiveKey(obj)
              Text = '';
                 for index = 1 : length(obj.FileTextsForActiveKey)
                 Text = [Text; sprintf('\nFile-codes for #%i group of data:\n', index)];
                 Text = [Text; cellfun(@(x) sprintf('%s\n', x), obj.FileTextsForActiveKey{index}, 'UniformOutput', false)];
            end
              
          end
          
          
          
      end
      
      methods (Access = private) % verify connection of all active files
        
        function obj = verifyFileConnection(obj)
            % VERIFYFILECONNECTION throws error when file-codes of active cannot be connected too;
            assert(~isempty(obj.FolderWithSourceData), 'Also set the folder with source data.')


            for index = 1 : obj.getNumberOfGroups

                FileCodesCurrentGroup =         obj.FileTextsForActiveKey{index};

                fileExists =                    cellfun(@(x) PMFile( obj.FolderWithSourceData, [ x, '.csv']).fileExists, FileCodesCurrentGroup);

                if min(fileExists) == 0

                       MissingFiles = FileCodesCurrentGroup(~fileExists, :);
                       cellfun(@(x) fprintf('Could not connect to file "%s/%s.csv".\n', obj.FolderWithSourceData, x), MissingFiles);
                       error('Check existence of this file in folder "%s".', obj.FolderWithSourceData)

                end


            end



            end
        
        
       end
    
     
     
    
    
end

