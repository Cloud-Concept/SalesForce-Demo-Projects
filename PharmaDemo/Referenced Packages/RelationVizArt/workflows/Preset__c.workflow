<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ITBRelViz_Set_Default_Unique_P</fullName>
        <description>Set&apos;s the default uid when the is default checkbox changes</description>
        <field>default_uid__c</field>
        <formula>IF (AND($RecordType.DeveloperName = &quot;Profile&quot;, Is_Default__c = true),$Profile.Id,
	IF(AND( $RecordType.DeveloperName = &quot;User&quot;,Is_Default__c = true) , $User.Id,
	IF(AND($RecordType.DeveloperName = &quot;all_Users&quot;,Is_Default__c = true), &quot;all_Users&quot;, &quot;&quot;)
)
)</formula>
        <name>ITBRelViz_Set_Default_Unique</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Relation_VizArt_Preset_uid_profile</fullName>
        <description>Updates the uid of a Profile</description>
        <field>uid__c</field>
        <formula>Name   &amp; &quot;|&quot; &amp;   ProfileID__c</formula>
        <name>Relation_VizArt_Preset_uid_profile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Relation_VizArt_Preset_uid_user</fullName>
        <description>Updates the uid-Field for Users</description>
        <field>uid__c</field>
        <formula>Name  &amp; &quot;|&quot; &amp;   User__c</formula>
        <name>Relation_VizArt_Preset_uid_user</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ITBRelViz_Check_Default_Unique</fullName>
        <actions>
            <name>ITBRelViz_Set_Default_Unique_P</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks the uniqueness of a preset which is set as &quot;default&quot;</description>
        <formula>OR(ISNEW(),ISCHANGED( Is_Default__c ),ISCHANGED(Name ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Relation_VizArt_Preset_uid</fullName>
        <actions>
            <name>Relation_VizArt_Preset_uid_profile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set&apos;s the uid-Field of the Preset for Presets</description>
        <formula>AND($RecordType.Name = &quot;Profile&quot;,OR(ISNEW(),ISCHANGED(Name),ISCHANGED(Name )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Relation_VizArt_Preset_uid_U</fullName>
        <actions>
            <name>Relation_VizArt_Preset_uid_user</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set&apos;s the uid-Field of the Preset for Users</description>
        <formula>AND($RecordType.Name = &quot;User&quot;,OR(ISNEW(),ISCHANGED(Name),ISCHANGED(Name )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
