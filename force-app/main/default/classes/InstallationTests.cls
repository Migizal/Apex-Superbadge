@isTest
private class InstallationTests {
    private static final String STRING_TEST = 'TEST';
    private static final String NEW_STATUS = 'New';
    private static final String WORKING = 'Working';
    private static final String CLOSED = 'Closed';
    private static final String REPAIR = 'Repair';
    private static final String REQUEST_ORIGIN = 'Web';
    private static final String REQUEST_TYPE = 'Routine Maintenance';
    private static final String REQUEST_SUBJECT = 'test subject';
    public static String CRON_EXP = ' 0 0 1 * * ?';

    @isTest
    static void testMaintenanceRequestNegative(){

        Vehicle__c vehicle = createVehicle();
        insert vehicle;
        Id vehicleId = vehicle.Id;

        Product2 Equipment = createEquip();
        insert Equipment;
        Id equipmentId = Equipment.Id;

        Case caseToUpdate = createMaintenanceRequest(vehicleId, equipmentId);
        insert caseToUpdate;

        Equipment_Maintenance_Item__c jp = createJobPart(equipmentId, caseToUpdate.Id);
        insert jp;

        Test.startTest();
        caseToUpdate.Status = WORKING;
        update caseToUpdate;
        Test.stopTest();

        List<Case> allRequests = [SELECT Id FROM Case];
        Equipment_Maintenance_Item__c jobPart = [
                                                SELECT Id 
                                                FROM Equipment_Maintenance_Item__c 
                                                WHERE Maintenance_Request__c = :caseToUpdate.Id
                                                ];
        System.assert(jobPart != null);
        System.assert(allRequests.size() == 1);
    }

    static void testWarehouseSync(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutService());
        Test.startTest();
            String jobId = System.schedule('WarehouseSyncSchedule', CRON_EXP, new WarehouseSyncSchedule());
            CronTrigger ct = [
                                SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                FROM CronTrigger 
                                WHERE Id = :jobId
                                ];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

    PRIVATE STATIC Vehicle__c createVehicle(){
        Vehicle__c Vehicle = new Vehicle__c(name= 'MonsterRV');
        return Vehicle;
    }

    PRIVATE STATIC Product2 createEquip(){
        Product2 equipment = new Product2(
                        name='OmniTool', 
                        Lifespan_Months__c=10,
                        Maintenance_Cycle__c= 10,
                        Replacement_Part__c= true);
        return equipment;
    }

    PRIVATE STATIC Case createMaintenanceRequest(Id vehicleId, Id equipmentId){
        Case cc = new Case(
                            Type=REPAIR, 
                            Status=NEW_STATUS, 
                            Origin=REQUEST_ORIGIN, 
                            Subject=REQUEST_SUBJECT, 
                            Equipment__c = equipmentId, 
                            Vehicle__c = vehicleId);
        return cc;
    }

    PRIVATE STATIC Equipment_Maintenance_Item__c createJobPart(Id equipmentId, Id requestId){
        Equipment_Maintenance_Item__c jp = new  Equipment_Maintenance_Item__c(
                                                            Equipment__c = equipmentId, 
                                                            Maintenance_Request__c = requestId);
        return jp;
    }
}