classdef Test_ParSessions < TestCase
	%% TEST_PARSESSIONS 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlparallel.Test_ParSessions % in . or the matlab path
	%          >> runtests mlparallel.Test_ParSessions:test_nameoffunc
	%          >> runtests(mlparallel.Test_ParSessions, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        np755path = '/Volumes/PassportStudio2/test/np755';
    end
    
	properties (Dependent)
        sessions
        petdirs
    end

    methods %% set/get
        function p = get.petdirs(this)
            if (isempty(this.petdirs_))
                this.petdirs_ = cell(1,length(this.sessions));
                for s = 1:length(this.sessions)
                    this.petdirs_{s} = mlpet.PETDirector.createFromSessionPath(this.sessions{s});
                end
            end
            p = this.petdirs_;
        end
        function s = get.sessions(this)
            s = { fullfile(this.np755path, 'mm01-020_p7377_2009feb5') ...
                  fullfile(this.np755path, 'mm05-001_p7936_2011nov18') };
        end
    end
    
	methods (Static)
        function cleanpet(session)
            toks = mlfourd.NamingRegistry.instance.tracerIds;
            for t = 1:length(toks)
                try
                    mlbash(sprintf('rm %s/fsl/%s*_gauss*mm*', session, toks{t}));
                catch ME
                    handexcept(ME);
                end
            end
        end
    end
       
    methods
 		function test_twoPets(this) 
 			import mlparallel.*;
            petdirs = this.petdirs; %#ok<*PROP>
            sessions = this.sessions;
            matlabpool('close', 'force', 'local');
            matlabpool('local', 2);
            parfor s = 1:2
                Test_ParSessions.cleanpet(sessions{s});
                petdirs{s}.coregisterAllPet;
            end
            matlabpool('close');
            assertTrue(lexist(fullfile(this.sessions{1}, 'ptr_on_t1_005_gauss3p8391mm.nii.gz'), 'file'));            
            assertTrue(lexist(fullfile(this.sessions{2}, 'ptr_on_t1_002_gauss3p8391mm.nii.gz'), 'file'));
 		end 
 		function this = Test_ParSessions(varargin) 
 			this = this@TestCase(varargin{:}); 
 		end% ctor 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        petdirs_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

