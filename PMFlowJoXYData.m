classdef PMFlowJoXYData
    %PMFLOWJOXYDATA Generate XYData objects from matrix files exported by FlowJo;
    %   Detailed explanation goes here
    
    properties (Access = private)
              
        % All experiments in this group should use the same files:
        FileManagerObject
        
        FlowJoGroupCodesFileName       
        FileIDCodesFileName 
        
        % different exports may require different files
        ParameterNamesFileName
        SelectedExperimentKey
        SelectedParameterName
        SelectedGroups
        
        MatchMeans = true
                    
    end
    
        properties (Access = private) % STATISTICS
        
            CenterType = 'Median';
            %CenterType = 'Mean';

            StatisticsTest = 'Student''s t-test';
          %  StatisticsTest = 'Mann-Whitney test';

        
        
        
        
        end
    
        
    
    methods % INITIALIZE:
        
        function obj = PMFlowJoXYData(varargin)
            %PMFLOWJOXYDATA Construct an instance of this class
            %   takes 3 arguments:
            % 1: homefolder-string: contains 
           switch length(varargin)
               
               case 3
                    obj.FileManagerObject      =                    varargin{1};               
                    obj.FlowJoGroupCodesFileName             =      varargin{2};           
                    obj.FileIDCodesFileName       =                 varargin{3};           
                   
               case 4
                   
               obj.FileManagerObject      =                    varargin{1};               
                    obj.FlowJoGroupCodesFileName             =      varargin{2};           
                    obj.FileIDCodesFileName       =                 varargin{3};   
                    obj.MatchMeans = varargin{4};
                   
           end
           
           
           
        end
        
        function obj = set.FileManagerObject(obj, Value)
            assert(ismethod(Value, 'getFloJoGroupFolder'), 'Wrong input.')
           obj.FileManagerObject = Value; 
        end
        
         function obj = set.FlowJoGroupCodesFileName(obj, Value)
             assert(ischar(Value), 'Wrong input.')
           obj.FlowJoGroupCodesFileName = Value; 
         end
        
          function obj = set.FileIDCodesFileName(obj, Value)
                assert(ischar(Value), 'Wrong input.')
           obj.FileIDCodesFileName = Value; 
          end
        
        
    end
    
        
         methods % GETTERS
        
        function XYData_CD3 = getXYData(obj, varargin)
            % GETXYDATA returns a specified PMXVsYDataContainer object from CXCR4_InVitroInhibition_OTI_EL4_CD3 experiments;
            % takes 2 arguments:
            % 1: name of wanted experiment-key;
            % 2: name of wanted parameter;
            % 3: filename specifying parameter names
            
            switch length(varargin)
               
                case 6
                    obj.SelectedExperimentKey =       varargin{1};
                    obj.SelectedParameterName =       varargin{2};
                    obj.ParameterNamesFileName =      varargin{3};
                    obj.SelectedGroups =              varargin{4}; 
                    XYData_CD3 =                      obj.getXYDataCommon(varargin{5}, varargin{6});
                    
                case 7
                   
                otherwise
                    error('Wrong input.')
                
                
            end
           
          
            
        end
        
        function dataSource = getFlowJoDataSource(obj, varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            switch length(varargin)
               
                case 0
                    
                case 2
                    obj.SelectedExperimentKey =         varargin{1};
                    obj.ParameterNamesFileName =        varargin{2};
                    
                otherwise
                    error('Wrong input.')
                
            end
  
                dataSource = PMFlowJoDataSource(...
                    obj.getGroupRowsObject, ...
                    obj.getRowTitlesObject ...
                    );
                
                dataSource = dataSource.setMatchMeansOfDifferentExperiments(obj.MatchMeans);
                   
           end
           
       
        
        
    end
    
    
   
    
    methods (Access = private) % GETTERS DATA
        
        function XYData = getXYDataCommon(obj, Type, varargin)

            switch Type
               
                case 'IndividualValues'
                    XYData =                obj.getGroupStatistics.getXYData(obj.SelectedGroups);
                    
                case 'PercentageInRange'
                    assert(length(varargin) == 1, 'Wrong input.')
                    Range = varargin{1};
                    assert(PMNumbers(Range).isNumericVector, 'Wrong input.')
                    XYData =                obj.getGroupStatistics.getXYData(obj.SelectedGroups);
                    XYData =                XYData.getPercentagesPerBin(varargin{1});
                    
                otherwise
                    error('Wrong input.')
                
            end
            
                XYData =                XYData.setName(obj.SelectedExperimentKey);
                XYData =                XYData.setYParameter(obj.SelectedParameterName);
                XYData =                XYData.setCenterType(obj.CenterType);
                XYData =                XYData.setPValueType(obj.StatisticsTest);
                
        end
        
        

        
      
        
        
    end
    
    methods (Access = private) % GETTERS FLOW-JO DATA
        
        function groupStatistics = getGroupStatistics(obj)
               groupStatistics =          ...
                   obj.getFlowJoDataSource.getGroupStatisticsListsForIndices(1).getGroupStatisticsWithParameterName(obj.SelectedParameterName);
                
            
        end
        
   
    
        
        
        
    end
    
    methods (Access = private) % GETTERS FUNDAMENTAL OBJECTS
        
        function MyGroupRows = getGroupRowsObject(obj)
                MyGroupRows =                     PMFlowJoGroupIndices(...
                                                        obj.getGroupRowsFolderName, ...
                                                        obj.FlowJoGroupCodesFileName,  ...
                                                        obj.getFileIDCodesObject...
                                                );

            
        end
        
         function myFileIDCodes = getFileIDCodesObject(obj)
                      myFileIDCodes =   PMFlowJoFileIDCodes(...
                        obj.getFolderNameForFileIDCodes,  ...
                        obj.SelectedExperimentKey, ...
                        obj.FileIDCodesFileName, ...
                        obj.getFolderWithSourceData...
            );
        
        
        
        
        end
        
        function myRowTitles = getRowTitlesObject(obj)
              myRowTitles =     PMRowTitles(...
                                    obj.getFolderNameWithRowTitles, ...
                                    obj.ParameterNamesFileName...
                                    );
              
            
        end
        
        
        
    end
    
    methods (Access = private) % GETTERS FOLDER NAMES
        
        function name = getGroupRowsFolderName(obj)
                name = obj.FileManagerObject.getFloJoGroupFolder;
        end
        
         function name = getFolderNameForFileIDCodes(obj)
             name = obj.FileManagerObject.getFlowJoNumberFolder;   
         end
         
         function FolderWithSourceData = getFolderWithSourceData(obj)
                FolderWithSourceData = [obj.FileManagerObject.getFlowJoNumberFolder, '/FlowJoExports'];                                                    
         end
         
         function name = getFolderNameWithRowTitles(obj)
             name = obj.FileManagerObject.getFlowJoNumberFolder;
         end
        
        
        
        
    end
    
    
end

