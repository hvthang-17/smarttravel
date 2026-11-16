package com.smarttravel.backend.common;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import org.springframework.beans.factory.annotation.Value;
import javax.imageio.stream.MemoryCacheImageInputStream;

@Service
public class ImageUploadService {
    private static final long MAX_BYTES = 5 * 1024 * 1024;
    private final Path uploadRoot;

    public ImageUploadService(@Value("${app.upload.directory:uploads}") String directory) {
        uploadRoot = Path.of(directory);
    }

    public Map<String, String> store(MultipartFile file, String directory) throws IOException {
        if (file == null || file.isEmpty() || file.getSize() > MAX_BYTES) {
            throw new IllegalArgumentException("Ảnh phải có dung lượng từ 1 byte đến 5MB");
        }
        String filename = Optional.ofNullable(file.getOriginalFilename()).orElse("").toLowerCase(Locale.ROOT);
        String extension = filename.contains(".") ? filename.substring(filename.lastIndexOf('.') + 1) : "";
        if (!Set.of("png", "jpg", "jpeg", "gif").contains(extension)) {
            throw new IllegalArgumentException("Chỉ chấp nhận ảnh PNG, JPG, GIF");
        }
        try (var source = file.getInputStream(); var input = new MemoryCacheImageInputStream(source)) {
            var readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) throw new IllegalArgumentException("Nội dung file không phải ảnh hợp lệ");
            ImageReader reader = readers.next();
            try {
                reader.setInput(input);
                String format = reader.getFormatName().toLowerCase(Locale.ROOT);
                if (format.equals("jpeg")) format = "jpg";
                String expected = extension.equals("jpeg") ? "jpg" : extension;
                if (!expected.equals(format) || (long) reader.getWidth(0) * reader.getHeight(0) > 25_000_000) {
                    throw new IllegalArgumentException("Định dạng ảnh không khớp hoặc kích thước ảnh vượt giới hạn");
                }
                var image = reader.read(0);
                Path folder = uploadRoot.resolve(directory);
                Files.createDirectories(folder);
                String storedName = UUID.randomUUID() + "." + format;
                Path target = folder.resolve(storedName);
                if (!ImageIO.write(image, format, target.toFile())) throw new IOException("Không thể lưu ảnh");
                return Map.of("url", "/uploads/" + directory + "/" + storedName, "filename", storedName);
            } finally {
                reader.dispose();
            }
        } catch (javax.imageio.IIOException ex) {
            throw new IllegalArgumentException("Không thể đọc nội dung ảnh", ex);
        }
    }

    public List<String> storeAll(List<MultipartFile> files, String directory) throws IOException {
        if (files == null || files.isEmpty() || files.size() > 10
                || files.stream().mapToLong(MultipartFile::getSize).sum() > 25 * 1024 * 1024) {
            throw new IllegalArgumentException("Chọn 1–10 ảnh, tổng dung lượng tối đa 25MB");
        }
        List<String> urls = new ArrayList<>();
        try {
            for (MultipartFile file : files) urls.add(store(file, directory).get("url"));
            return urls;
        } catch (IOException | RuntimeException ex) {
            for (String url : urls) Files.deleteIfExists(uploadRoot.resolve(url.substring("/uploads/".length())));
            throw ex;
        }
    }
}
