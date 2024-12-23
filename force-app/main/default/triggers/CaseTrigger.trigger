trigger CaseTrigger on Case (before insert, before update, before delete, after insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            CaseHandler.caseStatusUpdate(trigger.new);
        }

        if(trigger.isDelete){
            CaseHandler.preventCaseDeletion(trigger.old);
        }
    }

    if(trigger.isAfter){
        if(trigger.isInsert){
            CaseHandler.updateCaseNumOnAccount(trigger.new);
        }
    }
}