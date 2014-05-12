;==============================================================================
;
;   Matrix0s Kernel 0.1 Prototype
;   By Jerome "PsyKhaze" KASPER
;   Under Distributed License Copyright 2013/2014
;
;==============================================================================
;

BootPlace db 'KernelPath' ;
SystemRoot db 'SystemRoot' ;
; Provided By BootLoader
Load './Security/Security.asm';
Load './Drivers/Drivers.asm';
Load './ExecutionSystem/ExecutionSystem.asm';
Load './UserSystem/UserSystem.asm';
Load './FileSystems/FileSystems.asm';
Load './Network/Network.asm';
;Load All Generic Stuff
call 'KernelLoadMemorySecureAdressTranslation';
call 'KernelLoadMemorySecurePointing';
;Start MemoryAdressingModel
call 'KernelMapInitialLocalMemory', BootPlace;
call 'KernelLoadProtectedLongMode' ;
call 'KernelIntegrityCheck';
;Load Kernel binary and Check
if (IntegrityCheck=True)
{
  call 'KernelExecutionLevel',1;
  Load './SelfProber/SelfProber.asm';
  call 'KernelLoadResources' ;
  call 'KernelMakeSystemMap' ;
  call 'KernelDefaultConfigLoad' ;
  call 'KernelSystemConfigLoad', SystemRoot ;
  ; Enter Level 1 by establishing defaults
  if (SystemConfigLoaded=True)
  {
    call 'KernelExecutionLevel',2;
    Load './MathLib/MathLib.asm'
    Load './StringLib/StringLib.asm';
    Load './MediaLib/MediaLib.asm';
    call 'KernelLoadLib';
     ;Enter level 2 by by loading system "Lirairies"
    Load './Scheduler/Scheduler.asm'
    ;Memory Loacal Management
    call 'KernelLocalThreading';
    call 'KernelSetLocalUserMode';
    ;Finishing Starting up 'local' mode
    if(EnvCorrect=1)
    {
      call 'KernelExecutionLevel',3;
      call 'KernelLaunchDaemons';
      call 'KernelProbeNetwork';
      call 'KernelProbeRings';
      call 'KernelStartLocalSchedule';
      ;Enter level 2 by by starting Scheduling
      call 'KernelJoinRings';
      call 'KernelStartMetaSchedule';
      ;Join Ring if Possible and start MetaSchedule
      call 'KernelConsole';
      ;Start System Console
      call 'KernelGraphicMode';
      ;Start Graphic Mode
      call 'KernelProbeSystemRoot';
      ;Check For Main Start Point
      SystemRootApp db 'PathToSystemDesktop';
      while (State!=ERROR)
      {
        try{
          call 'KernelSCheduleExecuteStack',SystemRoot+'usr/apps/';
          ; Schedule execution Stack while ERROR
        }
        catch{
          call 'KernelRecoverFromError', ERRORMESSAGE ;
          ;if ERROR,try to recover
        }
        ; Kernel Main Loop
      }
    }
    else
    {
      call 'KernelReloadEnv';
      ;Reload Env until correct
    }
  else
  {
    call 'KernelDefaultConfig';
    ;Reload DefaultConfig until correct
  }
 }
 else
 {
   call 'KernelReloadFromBootLoader';
   ;Reload Kernel until correct
}
