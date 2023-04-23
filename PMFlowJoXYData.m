classdef PMFlowJoXYData
    %PMFLOWJOXYDATA Generate XYData objects from matrix files exported by FlowJo;
    %  This is an earlier version that takes objects and "parent-folders" as input;
    % there is a new version PMFlowJoReadExportedData
    

    properties (Access =private)

        FolderWithExportedData

        FileNameWithFilenameInfo

        FileNameWithGroupIndices

        FileNameWithRowTitles

    end

    properties (Access = private)
              
        % All experiments in this group should use the same files:
        
               
                    
    end
    
    properties (Access = private)

        % Specify data that should be read:
        
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
        
         function obj =     PMFlowJoXYData(varargin)
            %PMFLOWJOXYDATA Construct an instance of this class
            %   takes 3 arguments:
            % 1: homefolder-string: contains 
           switch length(varargin)
               
               case 3
                   error('Use 5 arguments.')

                    obj.FolderWithExportedData =        [ varargin{1}.getFlowJoNumberFolder, '/FlowJoExports'];            
                    obj.FileNameWithFilenameInfo =      [varargin{1}.getFlowJoNumberFolder, '/', varargin{3} ];
                     


                    obj.FileNameWithGroupIndices =      varargin{4};

                    obj.FlowJoGroupCodesFileName   =      varargin{2};           
                 
                   

                     name =                      obj.FileManagerObject.getFloJoGroupFolder;


               case 4
                   error('Use 5 arguments.')

                    obj.FolderWithExportedData =      [ varargin{1}.getFlowJoNumberFolder, '/FlowJoExports'];  
                    obj.FileNameWithFilenameInfo =      [varargin{1}.getFlowJoNumberFolder, '/',varargin{3} ];
                    
                            
                    obj.FlowJoGroupCodesFileName             =      varargin{2};           
                 
                    obj.MatchMeans =                                varargin{4};

               case 5


                    obj.FolderWithExportedData =        varargin{1};
                    obj.FileNameWithFilenameInfo =      varargin{2};
                    obj.FileNameWithRowTitles =         varargin{3};
                    obj.FileNameWithGroupIndices =      varargin{4};
                    obj.MatchMeans =                    varargin{5};

                   
           end
           
           
                
           
        end
     
   
  
        
        
    end
    
        
     methods % GETTERS
        
        function XYData_CD3 = getXYData(obj, varargin)
            % GETXYDATA returns a specified PMXVsYDataContainer object from CXCR4_InVitroInhibition_OTI_EL4_CD3 experiments;
            % takes 4 to 5 arguments arguments:
            % 1: name of wanted experiment-key;
            % 2: name of wanted parameter;
            % 3: selected groups
            % 4: type:  'IndividualValues', 'PercentageInRange'
            % 5: range
           
            
            switch length(varargin)

                case {4}

                     obj.SelectedExperimentKey =       varargin{1};
                    obj.SelectedParameterName =       varargin{2};
                 %   obj.ParameterNamesFileName =      varargin{3};
                    obj.SelectedGroups =              varargin{3}; 

                  
                   
                    try
                        XYData_CD3 =                      obj.getXYDataCommon(varargin{4});
                    catch ME
                        rethrow(ME)
                    end

                case { 5}

                    XYData_CD3 =                      obj.getXYDataCommon(varargin{4}, varargin{5});

               
                case 6

                    error('Not supported. Use 5 inputs instead.')
                    obj.SelectedExperimentKey =       varargin{1};
                    obj.SelectedParameterName =       varargin{2};
                 %  obj.ParameterNamesFileName =      varargin{3};
                    obj.SelectedGroups =              varargin{4}; 
                    XYData_CD3 =                      obj.getXYDataCommon(varargin{5}, varargin{6});
                    
                case 7
                      error('Not supported. Use 5 inputs instead.')
                   
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
  
            try
                dataSource = PMFlowJoDataSource(...
                    obj.getGroupIndicesObject, ...
                    obj.getParameterObject ...
                    );
                
                    dataSource = dataSource.setMatchMeansOfDifferentExperiments(obj.MatchMeans);

            catch ME
                rethrow(ME)


            end
                   
           end
                
    end
    
    
   
    
    methods (Access = private) % GETTERS DATA
        
        function XYData = getXYDataCommon(obj, Type, varargin)
            % getXYDataCommon returns PMXVsYDataContainer
            switch Type
               
                case 'IndividualValues'
                        MyFlowJoDataSource =        obj.getFlowJoDataSource;
                        MyGroupStatisticsLists =    MyFlowJoDataSource.getGroupStatisticsLists;
                        groupStatistics =           arrayfun(@(x) x.getGroupStatisticsWithParameterName(obj.SelectedParameterName), MyGroupStatisticsLists);
                        XYData =                    arrayfun(@(x) x.getXYData(obj.SelectedGroups), groupStatistics);
                    
                case 'PercentageInRange'
                    assert(length(varargin) == 1, 'Wrong input.')
                    Range = varargin{1};
                    assert(PMNumbers(Range).isNumericVector, 'Wrong input.')

                      MyFlowJoDataSource =        obj.getFlowJoDataSource;
                       MyGroupStatisticsLists =    MyFlowJoDataSource.getGroupStatisticsLists;
                        groupStatistics =           arrayfun(@(x) x.getGroupStatisticsWithParameterName(obj.SelectedParameterName), MyGroupStatisticsLists);

                 

                    XYData =                groupStatistics.getXYData(obj.SelectedGroups);
                    XYData =                XYData.getPercentagesPerBin(varargin{1});
                    
                otherwise
                    error('Wrong input.')
                
            end
            
                XYData =              arrayfun(@(x)x.setName(obj.SelectedExperimentKey), XYData);
                XYData =                 arrayfun(@(x)x.setYParameter(obj.SelectedParameterName), XYData);
                XYData =                 arrayfun(@(x)x.setCenterType(obj.CenterType), XYData);
                XYData =                 arrayfun(@(x)x.setPValueType(obj.StatisticsTest), XYData);
                
        end
        
        

        
      
        
        
    end
    
    methods (Access = private) % GETTERS FLOW-JO DATA
        
    
        
   
    
        
        
        
    end
    
    methods (Access = private) % GETTERS FUNDAMENTAL OBJECTS
        
        function MyGroupRows = getGroupIndicesObject(obj)


                [MyFolder, Name, Extension ] =              fileparts( obj.FileNameWithGroupIndices);
                MyGroupRows =                     PMFlowJoGroupIndices(...
                                                        MyFolder, ...
                                                        [ Name, Extension ],  ...
                                                        obj.getFileIDCodesObject...
                                                );

            
        end
        
         function myFileIDCodes = getFileIDCodesObject(obj)


              [MyFolder, Name, Extension] =              fileparts( obj.FileNameWithFilenameInfo);

                      myFileIDCodes =   PMFlowJoFileIDCodes(...
                        MyFolder,  ...
                        obj.SelectedExperimentKey, ...
                        [ Name, Extension], ...
                        obj.FolderWithExportedData...
            );
        
        
        
        
        end
        
        function myRowTitles = getParameterObject(obj)

            [MyFolder, Name, Extension ] = fileparts(   obj.FileNameWithRowTitles);
            


              myRowTitles =     PMRowTitles(...
                                    MyFolder, ...
                                   [Name, Extension] ...
                                    );
                          
        end
  
    end
    
    methods (Access = private) % GETTERS FOLDER NAMES
        
      
        
  
       
      
        
        
        
        
    end
    
    
end

