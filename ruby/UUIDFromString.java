import java.util.*;

public class UUIDFromString {
   public static void main(String[] args) {
      UUID uid = UUID.nameUUIDFromBytes(args[0].getBytes());
      System.out.println(uid);
   }
}