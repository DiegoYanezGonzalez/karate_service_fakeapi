package features;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class runner {

    @Test
    void flujoCarroDeCompra(){
        Results result = Runner.path("dyanez/flujoCarroCompra.feature").relativeTo(getClass()).parallel(1);
        assertEquals(0,result.getFailCount(),result.getErrorMessages());
 }

}
