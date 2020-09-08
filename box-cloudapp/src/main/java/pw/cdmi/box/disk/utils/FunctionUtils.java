package pw.cdmi.box.disk.utils;

public final class FunctionUtils
{
    private FunctionUtils()
    {
        
    }
    
    public static boolean isCMB()
    {
        try
        {
            Class.forName("com.huawei.sharedrive.cloudapp.cmb.control.CMBConstants");
            return false;
        }
        catch (ClassNotFoundException e)
        {
            return false;
        }
    }
    
}
