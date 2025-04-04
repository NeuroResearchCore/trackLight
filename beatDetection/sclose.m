function [HDR] = sclose(HDR)
% SCLOSE closes the file with the handle HDR
% [HDR] = sclose(HDR)
%    HDR.FILE.status = -1 if file could not be closed.
%    HDR.FILE.status = 0 indicates the file has been closed.
%
% see also: SOPEN, SREAD, SSEEK, STELL, SCLOSE, SWRITE

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

%	$Revision: 1.19 $
%	$Id: sclose.m,v 1.19 2006/02/13 09:22:54 schloegl Exp $
%	(C) 1997-2005 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the BIOSIG-toolbox http://biosig.sf.net/


if (HDR.FILE.FID<0) | ~HDR.FILE.OPEN, 
        HDR.FILE.status = -1;
        %fprintf(HDR.FILE.stderr,'Warning SCLOSE (%s): invalid handle\n',HDR.FileName);
end;

if HDR.FILE.OPEN >= 2,          % write-open of files 
	% check file length - simple test for file integrity         
        EndPos = ftell(HDR.FILE.FID);          % get file length
        % force file pointer to the end, otherwise Matlab 6.5 R13 on PCWIN
        status = fseek(HDR.FILE.FID,0,'eof');
        
        if strcmp(HDR.TYPE,'BKR');
                if HDR.NS<1, 
                        fprintf(HDR.FILE.stderr,'Error SCLOSE BKR: number of channels (HDR.NS) must be larger than zero.\n');
                        return;
                end;
                if HDR.NRec<1, 
                        fprintf(HDR.FILE.stderr,'Error SCLOSE BKR: number of blocks (HDR.NRec) must be larger than zero.\n');
                        return;
                end;
                % check file length and write Headerinfo.
                HDR.SPR = (EndPos-HDR.HeadLen)/(HDR.NRec*HDR.NS*2);
                if isnan(HDR.SPR), HDR.SPR=0; end;
                if HDR.FILE.OPEN==3;
                        if any(isnan([HDR.NRec,HDR.NS,HDR.SPR,HDR.DigMax,HDR.PhysMax,HDR.SampleRate])), 	% if any unknown, ...	
                                fprintf(HDR.FILE.stderr,'Error SCLOSE BKR: some important header information is still undefined (i.e. NaN).\n');
                                fprintf(HDR.FILE.stderr,'\t HDR.NRec,HDR.NS,HDR.SPR,HDR.DigMax,HDR.PhysMax,HDR.SampleRate must be defined.\n');
                                fprintf(HDR.FILE.stderr,'\t Try again.\n');
                        end;
                        
                        fclose(HDR.FILE.FID);
                        HDR.FILE.FID = fopen(HDR.FileName,'r+');
                        
                        count=fwrite(HDR.FILE.FID,HDR.VERSION,'short');	        % version number of header
                        count=fwrite(HDR.FILE.FID,HDR.NS,'short');	        % number of channels
                        count=fwrite(HDR.FILE.FID,HDR.SampleRate,'short');      % sampling rate
                        count=fwrite(HDR.FILE.FID,HDR.NRec,'int32');            % number of trials: 1 for untriggered data
                        count=fwrite(HDR.FILE.FID,HDR.SPR,'uint32');            % samples/trial/channel
                        count=fwrite(HDR.FILE.FID,HDR.PhysMax,'short');		% Kalibrierspannung
                        count=fwrite(HDR.FILE.FID,HDR.DigMax, 'short');		% Kalibrierwert
                        count=fwrite(HDR.FILE.FID,zeros(4,1),'char');        
                        count=fwrite(HDR.FILE.FID,[HDR.Filter.LowPass,HDR.Filter.HighPass],'float'); 
                        
                        fseek(HDR.FILE.FID,32,'bof');
                        HDR.FLAG.TRIGGERED   = HDR.NRec>1;	% Trigger Flag
                        count = fwrite(HDR.FILE.FID,HDR.FLAG.TRIGGERED,'int16');           % FLAG TRIGGERED
                end;

	elseif strcmp(HDR.TYPE,'EDF') | strcmp(HDR.TYPE,'BDF') | strcmp(HDR.TYPE,'GDF'),
         	tmp = floor((EndPos - HDR.HeadLen) / HDR.AS.bpb);  % calculate number of records
                if isnan(tmp)
                	tmp = 0; 
                end;	

                if (HDR.NRec~=tmp)
                       if ~any(HDR.FILE.PERMISSION=='z')
                               HDR.NRec=tmp;
                               fseek(HDR.FILE.FID,236,'bof');
                               if strcmp(HDR.TYPE,'GDF')
                                        c=fwrite(HDR.FILE.FID,[HDR.NRec,0],'int32');
                               else	
                                        fprintf(HDR.FILE.FID,'%-8i',HDR.NRec);
                                end;
                        else    %% due to a limitation in zlib
                                fprintf(HDR.FILE.stderr,'ERROR SCLOSE: number-of-records-field (HDR.NRec) could not be updated in file %s.\n',HDR.FileName);
                        end;
                end;

                if strcmp(HDR.TYPE,'GDF') & isfield(HDR,'EVENT'),
                	if ~all([HDR.NS, HDR.NRec, HDR.AS.bpb]>0)
                		HDR.AS.EVENTTABLEPOS = HDR.HeadLen; 
                	else
	                        HDR.AS.EVENTTABLEPOS = HDR.HeadLen+HDR.AS.bpb*HDR.NRec;
	                end; 
			len = [length(HDR.EVENT.POS),length(HDR.EVENT.TYP)]; 
                        EVENT.Version = 1;
                        if isfield(HDR.EVENT,'CHN') & isfield(HDR.EVENT,'DUR'), 
                                if any(HDR.EVENT.CHN) | any(HDR.EVENT.DUR),
                                        EVENT.Version = 3;
					len = [len,length(HDR.EVENT.CHN),length(HDR.EVENT.DUR)];
                                end;
                        end;

                        if any(len~=len(1))
                                fprintf(HDR.FILE.stderr,'Error SCLOSE-GDF: cannot write Event table, file %s not closed.\n',HDR.FileName);
				return;
                        else
                                status  = fseek(HDR.FILE.FID,HDR.HeadLen+HDR.AS.bpb*HDR.NRec,'bof');
                                %status = fseek(HDR.FILE.FID,0,'eof');
                                if ftell(HDR.FILE.FID)~=HDR.AS.EVENTTABLEPOS,
                                        fprintf(HDR.FILE.stderr,'Warning SCLOSE-GDF: inconsistent GDF file\n');
                                end
				if ~isfield(HDR.EVENT,'SampleRate'), 
					HDR.EVENT.SampleRate = HDR.SampleRate; 
				end;
				
				% write eventtable info: Version, SampleRate & length
				if (HDR.VERSION<1.94)
					tmp = HDR.EVENT.SampleRate;
					tmp = [EVENT.Version,mod(tmp,256),floor(mod(tmp,65536)/256),floor(tmp/65536)];
	                                fwrite(HDR.FILE.FID,tmp,'uint8');  
	                                fwrite(HDR.FILE.FID,length(HDR.EVENT.POS),'uint32');
				else
					tmp = length(HDR.EVENT.POS);
					tmp = [EVENT.Version,mod(tmp,256),floor(mod(tmp,65536)/256),floor(tmp/65536)];
	                                fwrite(HDR.FILE.FID,tmp,'uint8');  
	                                fwrite(HDR.FILE.FID,HDR.EVENT.SampleRate,'float32');				
				end;
				
				% write table 
                                c1 = fwrite(HDR.FILE.FID,HDR.EVENT.POS,'uint32');
                                c2 = fwrite(HDR.FILE.FID,HDR.EVENT.TYP,'uint16');
                                c3 = length(HDR.EVENT.POS); c4 = c3; 
                                if EVENT.Version==3;
                                        c3 = fwrite(HDR.FILE.FID,HDR.EVENT.CHN,'uint16');
                                        c4 = fwrite(HDR.FILE.FID,HDR.EVENT.DUR,'uint32');
                                end;
                                if any([c1,c2,c3,c4]~=length(HDR.EVENT.POS))
                                        fprintf(2,'\nError SCLOSE: writing of EVENTTABLE failed. File %s not closed.\n', HDR.FileName);
                                        return;
                                end
                        end;
                end;

        elseif strcmp(HDR.TYPE,'CFWB');
                tmp = (EndPos-HDR.HeadLen)/HDR.AS.bpb
                if isnan(tmp), tmp=0; end;
                if (tmp~=HDR.NRec);
                        if ~any(HDR.FILE.PERMISSION=='z')
                                HDR.NRec = tmp;
                                fseek(HDR.FILE.FID,14*4,-1);
                                count = fwrite(HDR.FILE.FID,HDR.NRec,'int32');           % channels
                        else
                                fprintf(HDR.FILE.stderr,'ERROR SCLOSE (CFWB): number-of-samples-field (HDR.SPR) could not be updated in file %s.\n',HDR.FileName);
                        end;
                end;
                
        elseif strcmp(HDR.TYPE,'SND');
                tmp = (EndPos-HDR.HeadLen)/HDR.AS.bpb;
                if isnan(tmp), tmp=0; end;
                if (HDR.FILE.OPEN==3) & (tmp~=HDR.SPR);
                        if ~any(HDR.FILE.PERMISSION=='z')
                                HDR.SPR = tmp;
                                fseek(HDR.FILE.FID,8,'bof');
                                count = fwrite(HDR.FILE.FID,HDR.SPR*HDR.AS.bpb,'uint32');           % bytes
                                fseek(HDR.FILE.FID,20,-1);
                                count = fwrite(HDR.FILE.FID,HDR.NS,'uint32');           % channels
                        else
                                fprintf(HDR.FILE.stderr,'ERROR SCLOSE (SND): fields HDR.SPR and HDR.NS could not be updated in file %s.\n',HDR.FileName);
                        end;
		end;
                
        elseif strcmp(HDR.TYPE,'AIF');
                if HDR.FILE.OPEN==3;
                        fseek(HDR.FILE.FID,4,-1);
                        count = fwrite(HDR.FILE.FID,EndPos-8,'uint32');           % bytes
                        fseek(HDR.FILE.FID,HDR.WAV.posis(2),-1);
                        count = fwrite(HDR.FILE.FID,EndPos-4-HDR.WAV.posis(2),'uint32');           % channels
                end;
                
        elseif strcmp(HDR.TYPE,'WAV') ;
                if HDR.FILE.OPEN==3;
                        fseek(HDR.FILE.FID,4,-1);
                        count = fwrite(HDR.FILE.FID,EndPos-16,'uint32');           % bytes
                        fseek(HDR.FILE.FID,HDR.WAV.posis(2),-1);
                        count = fwrite(HDR.FILE.FID,EndPos-4-HDR.WAV.posis(2),'uint32');           % channels
                end;
        end;
end;

if 0,
elseif strcmp(HDR.TYPE,'ZIP')
        [SUCCESS,MESSAGE,MESSAGEID] = rmdir(HDR.ZIP.TEMPDIR,'s');

elseif strcmp(HDR.TYPE,'FIF') & HDR.FILE.OPEN;
        global FLAG_NUMBER_OF_OPEN_FIF_FILES
        rawdata('close');
        HDR.FILE.OPEN = 0;
        HDR.FILE.status = 0;
        FLAG_NUMBER_OF_OPEN_FIF_FILES = FLAG_NUMBER_OF_OPEN_FIF_FILES-1; 
        
elseif strmatch(HDR.TYPE,{'ADI','GTEC','LABVIEW','MAT','MAT4','MAT5','native','XML','XML-FDA','SierraECG'}),
        HDR.FILE.OPEN = 0;
        
elseif HDR.FILE.OPEN,
        HDR.FILE.OPEN = 0;
        HDR.FILE.status = fclose(HDR.FILE.FID);
end;
        
