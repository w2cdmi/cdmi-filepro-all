
package pw.cdmi.file.engine.core.util;

import java.io.File;
import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 
 * @author s90006125
 *
 */
public final class FileUtils
{
    private FileUtils()
    {
    }
    
    private static final Logger LOGGER = LoggerFactory.getLogger(FileUtils.class);
    
    public static String getCanonicalPathWithOutException(File file)
    {
        if(null == file)
        {
            LOGGER.warn("arg is null.");
            return null;
        }
        
        try
        {
            return file.getCanonicalPath();
        }
        catch (IOException e)
        {
            LOGGER.warn("getCanonicalPath failed", e);
            return null;
        }
    }
}
