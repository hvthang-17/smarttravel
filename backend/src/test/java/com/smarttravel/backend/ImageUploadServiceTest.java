package com.smarttravel.backend;

import com.smarttravel.backend.common.ImageUploadService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.nio.file.*;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class ImageUploadServiceTest {
    @TempDir Path root;

    private MockMultipartFile png(String filename) throws Exception {
        var bytes = new ByteArrayOutputStream();
        ImageIO.write(new BufferedImage(2, 2, BufferedImage.TYPE_INT_RGB), "png", bytes);
        return new MockMultipartFile("file", filename, "image/png", bytes.toByteArray());
    }

    @Test
    void storesDecodedImageWithGeneratedFilenameInsideUploadRoot() throws Exception {
        var result = new ImageUploadService(root.toString()).store(png("../../sample.png"), "categories");
        Path saved = root.resolve("categories").resolve(result.get("filename"));
        assertTrue(Files.exists(saved));
        assertEquals(2, ImageIO.read(saved.toFile()).getWidth());
        assertEquals("/uploads/categories/" + result.get("filename"), result.get("url"));
    }

    @Test
    void rejectsFakeImageMismatchedExtensionSvgAndOversizedFiles() throws Exception {
        var service = new ImageUploadService(root.toString());
        assertThrows(IllegalArgumentException.class, () -> service.store(
                new MockMultipartFile("file", "fake.png", "image/png", "<script>alert(1)</script>".getBytes()), "categories"));
        assertThrows(IllegalArgumentException.class, () -> service.store(png("fake.jpg"), "categories"));
        assertThrows(IllegalArgumentException.class, () -> service.store(png("fake.svg"), "categories"));
        assertThrows(IllegalArgumentException.class, () -> service.store(
                new MockMultipartFile("file", "large.png", "image/png", new byte[5 * 1024 * 1024 + 1]), "categories"));
    }

    @Test
    void invalidBatchRemovesImagesWrittenEarlierInThatBatch() throws Exception {
        var service = new ImageUploadService(root.toString());
        assertThrows(IllegalArgumentException.class, () -> service.storeAll(List.of(png("valid.png"), png("invalid.svg")), "destinations"));
        try (var files = Files.list(root.resolve("destinations"))) { assertEquals(0, files.count()); }
    }
}
