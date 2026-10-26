import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class SqlRunner {
    public static void main(String[] args) throws Exception {
        String file = args[0];
        String url = "jdbc:mysql://127.0.0.1:3306/?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true&allowMultiQueries=true";
        String sql = new String(Files.readAllBytes(Path.of(file)), StandardCharsets.UTF_8);
        try (Connection c = DriverManager.getConnection(url, "root", "123456");
             Statement st = c.createStatement()) {
            st.execute(sql);
            System.out.println("[OK] jianlai.sql executed");
            ResultSet rs = st.executeQuery("SELECT id, uid, sect, status, create_time FROM jianlai.sys_user");
            while (rs.next()) {
                System.out.println("  -> " + rs.getLong("id") + " | " + rs.getString("uid")
                        + " | " + rs.getString("sect") + " | " + rs.getInt("status")
                        + " | " + rs.getTimestamp("create_time"));
            }
        }
    }
}
