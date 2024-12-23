trigger AccountTrigger on Account (before update, after undelete, after update, after insert) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
            AccountHandler.updateAccountError(trigger.new);
        }

        if(trigger.isInsert){
            AccountHandler.SetSalesRep(trigger.new);
        }
    }

    if(trigger.isAfter){
        if(trigger.isUpdate){
            AccountHandler.updateContactWebsite(trigger.new);
            AccountHandler.createNEmployees(trigger.new);
        }

        if(trigger.isInsert){
            AccountHandler.createContactAuto(trigger.new);
        }

        if(trigger.isUndelete){
            AccountHandler.setActiveOnUndelete(trigger.new);
        }
    }
}