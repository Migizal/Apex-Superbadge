@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    static void warehouseSyncScheduleTest(){
        String schTime = '00 00 01 * * ?';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String JobId = System.schedule('Warehouse Schedule Test', schTime, new WarehouseSyncSchedule());
        Test.stopTest();

        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE NextFireTime > TODAY];
        System.assertEquals(JobId, ct.Id, 'Schedule');
    }
}